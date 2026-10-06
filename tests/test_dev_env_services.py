"""Run with python3 -m unittest discover -s tests -v (requires PHP and jq)."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
LANDO = json.dumps({"mailpit": {}, "photon": {"healthy": True},
                    "elasticsearch": {"service": "elasticsearch"},
                    "demo-app-code": {"service": "demo-app-code"}})

# Only external container commands are adapted; shell branches, jq and PHP run natively.
ADAPTER = """#!/bin/sh
case "$(basename "$0")" in
  phpenmod) touch "$TEST_ROOT/$1.enabled" ;;
  phpdismod) rm -f "$TEST_ROOT/$1.enabled" ;;
  php-fpm|tput|mysqladmin) ;;
  mysql) cat >/dev/null ;;
  curl) touch "$TEST_ROOT/es-ready"; echo '{"status":"yellow"}' ;;
  wp)
    case "$*" in
      'core is-installed '*) test -f "$TEST_ROOT/installed" ;;
      'core install '*) touch "$TEST_ROOT/installed" ;;
      'config set --quiet '* )
        printf "define( '%s', %s );\\n" "$4" "$5" >> "$TEST_ROOT/wp/config/wp-config.php" ;;
      'cli has-command vip-search')
        php -r 'require $argv[1]; exit(defined("VIP_ENABLE_VIP_SEARCH") && VIP_ENABLE_VIP_SEARCH ? 0 : 1);' "$TEST_ROOT/wp/config/wp-config.php" ;;
      '--color vip-search index --skip-confirm --setup') touch "$TEST_ROOT/indexed" ;;
    esac ;;
  *) exit 1 ;;
esac
"""


class DevEnvServices(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for directory in ("bin", "wp/config", "wp/wp-includes/pomo", "wp/wp-content/mu-plugins"):
            (self.root / directory).mkdir(parents=True)
        (self.root / "wp/wp-includes/pomo/mo.php").touch()
        self.config = self.root / "wp/config/wp-config.php"
        self.config.write_text("<?php\n")
        shutil.copytree(ROOT / "wordpress/dev-tools", self.root / "dev-tools")
        for command in ("phpenmod", "phpdismod", "php-fpm", "tput", "mysqladmin", "mysql", "curl", "wp"):
            path = self.root / "bin" / command
            path.write_text(ADAPTER)
            path.chmod(0o755)
        self.env = {key: value for key, value in os.environ.items()
                    if not key.startswith(("VIP_", "LANDO_", "ENABLE_", "XDEBUG"))}
        self.env.update(PATH=f"{self.root / 'bin'}:{os.environ['PATH']}", TEST_ROOT=str(self.root))

    def run_script(self, source, settings):
        # Redirect only absolute container paths, so tests never touch host /wp or /dev-tools.
        script = (ROOT / source).read_text().replace("/wp/", str(self.root / "wp") + "/")
        script = script.replace("--path=/wp", "--path=" + str(self.root / "wp"))
        script = script.replace("/dev-tools/", str(self.root / "dev-tools") + "/")
        script = script.replace("/usr/sbin/php-fpm", str(self.root / "bin/php-fpm"))
        path = self.root / "script.sh"
        path.write_text(script)
        return subprocess.run(["sh", str(path), "db", "root", "example.test", "Demo"],
                              env=self.env | settings, capture_output=True, text=True, timeout=10, check=True)

    def constants(self, source, settings, prelude=""):
        code = "define('ABSPATH', $argv[2]); " + prelude
        code += "require $argv[1]; echo json_encode(array_map(fn($k) => defined($k) ? constant($k) : null, "
        code += "['FILES_ACCESS_TOKEN', 'VIP_ENABLE_VIP_SEARCH', 'VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION']));"
        result = subprocess.run(["php", "-c", str(ROOT / "php-fpm/rootfs-php/cli/php.ini"),
                                 "-r", code, str(source), str(self.root / "wp") + "/"],
                                env=self.env | settings, capture_output=True, text=True, check=True)
        self.assertEqual(result.stderr, "")
        return json.loads(result.stdout)

    def test_mailpit_explicit_setting_overrides_lando(self):
        for settings, enabled in (({"VIP_DEVENV_MAILPIT": "1"}, True),
                                  ({"VIP_DEVENV_MAILPIT": "0", "LANDO_INFO": LANDO}, False),
                                  ({"LANDO_INFO": LANDO}, True), ({}, False)):
            with self.subTest(settings=settings):
                self.run_script("php-fpm/rootfs/usr/local/bin/run.sh", settings)
                self.assertEqual((self.root / "mailpit.enabled").exists(), enabled)

    def test_photon_setting_controls_local_token_and_preserves_custom_token(self):
        for settings, token, prelude in (({"VIP_DEVENV_PHOTON": "1"}, "local-dev-token", ""),
                                        ({"VIP_DEVENV_PHOTON": "0", "LANDO_INFO": LANDO}, None, ""),
                                        ({"LANDO_INFO": LANDO}, "local-dev-token", ""),
                                        ({"LANDO_INFO": '{"photon":{"healthy":false}}'}, None, ""),
                                        ({}, None, ""),
                                        ({"VIP_DEVENV_PHOTON": "1", "LANDO_INFO": LANDO}, "custom", "define('FILES_ACCESS_TOKEN', 'custom');")):
            with self.subTest(settings=settings, prelude=prelude):
                self.assertEqual(self.constants(ROOT / "wordpress/dev-tools/wp-config-defaults.php",
                                                settings, prelude)[0], token)

    def test_search_is_enabled_and_indexed_only_for_fresh_demo(self):
        for settings, existing, enabled, ready in (
                ({"VIP_DEVENV_ELASTICSEARCH": "1", "VIP_DEVENV_DEMO_APP": "1"}, False, True, True),
                ({"VIP_DEVENV_ELASTICSEARCH": "0", "ENABLE_ELASTICSEARCH": "1", "LANDO_INFO": LANDO}, False, False, False),
                ({"VIP_DEVENV_ELASTICSEARCH": "1", "VIP_DEVENV_DEMO_APP": "0", "LANDO_INFO": LANDO}, False, False, True),
                ({"VIP_DEVENV_ELASTICSEARCH": "1"}, False, False, True),
                ({"LANDO_INFO": LANDO}, False, True, True),
                ({"VIP_DEVENV_ELASTICSEARCH": "1", "VIP_DEVENV_DEMO_APP": "1"}, True, False, True),
                ({"ENABLE_ELASTICSEARCH": "1"}, False, False, True)):
            with self.subTest(settings=settings, existing=existing):
                self.config.write_text("<?php\n")
                for marker in ("installed", "indexed", "es-ready"):
                    (self.root / marker).unlink(missing_ok=True)
                if existing:
                    (self.root / "installed").touch()
                self.run_script("wordpress/dev-tools/setup.sh", settings)
                self.assertEqual(self.constants(self.config, settings)[1:], [True, True] if enabled else [None, None])
                self.assertEqual((self.root / "indexed").exists(), enabled)
                self.assertEqual((self.root / "es-ready").exists(), ready)


if __name__ == "__main__":
    unittest.main()
