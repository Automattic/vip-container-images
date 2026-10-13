#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/vip-service-tests.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' 0
trap 'exit 1' 1 2 3 15
command -v php >/dev/null
command -v jq >/dev/null
LANDO='{"mailpit":{},"photon":{"healthy":true},"elasticsearch":{"service":"elasticsearch"},"demo-app-code":{"service":"demo-app-code"}}'
cases=0

mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/wp/config" "$TEST_ROOT/wp/wp-includes/pomo" "$TEST_ROOT/wp/wp-content/mu-plugins"
touch "$TEST_ROOT/wp/wp-includes/pomo/mo.php"
cp -R "$ROOT/wordpress/dev-tools" "$TEST_ROOT/dev-tools"

# Adapt external container commands; execute the actual shell branches, jq and PHP.
cat > "$TEST_ROOT/bin/adapter" <<'SH'
#!/bin/sh
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
      'config set --quiet '*) printf "define( '%s', %s );\n" "$4" "$5" >> "$TEST_ROOT/wp/config/wp-config.php" ;;
      'cli has-command vip-search')
        php -r 'require $argv[1]; exit(defined("VIP_ENABLE_VIP_SEARCH") && VIP_ENABLE_VIP_SEARCH ? 0 : 1);' "$TEST_ROOT/wp/config/wp-config.php" ;;
      '--color vip-search index --skip-confirm --setup') touch "$TEST_ROOT/indexed" ;;
    esac ;;
  *) exit 1 ;;
esac
SH
chmod +x "$TEST_ROOT/bin/adapter"
for command in phpenmod phpdismod php-fpm tput mysqladmin mysql curl wp; do
  ln -s adapter "$TEST_ROOT/bin/$command"
done

expect() {
  if [ "$1" != "$2" ]; then
    printf 'FAIL: %s: expected %s, got %s\n' "$3" "$1" "$2" >&2
    exit 1
  fi
}

marker() {
  if [ -f "$TEST_ROOT/$1" ]; then expect "$2" 1 "$1"; else expect "$2" 0 "$1"; fi
}

run_script() {
  # Redirect absolute container paths so no command touches host /wp or /dev-tools.
  sed -e "s|/wp/|$TEST_ROOT/wp/|g" -e "s|--path=/wp|--path=$TEST_ROOT/wp|g" \
    -e "s|/dev-tools/|$TEST_ROOT/dev-tools/|g" \
    -e "s|/usr/sbin/php-fpm|$TEST_ROOT/bin/php-fpm|g" "$ROOT/$1" > "$TEST_ROOT/script.sh"
  shift
  if ! env -i PATH="$TEST_ROOT/bin:$PATH" TEST_ROOT="$TEST_ROOT" "$@" \
    sh "$TEST_ROOT/script.sh" db root example.test Demo > "$TEST_ROOT/script.log" 2>&1; then
    cat "$TEST_ROOT/script.log" >&2
    exit 1
  fi
}

constants() {
  # Use the image's actual PHP configuration, including its $_ENV population.
  source=$1; token=$2; shift 2
  if ! env -i PATH="$PATH" "$@" php -c "$ROOT/php-fpm/rootfs-php/cli/php.ini" -r '
    define("ABSPATH", $argv[2]);
    if ($argv[3] !== "") { define("FILES_ACCESS_TOKEN", $argv[3]); }
    require $argv[1];
    echo json_encode(array_map(fn($k) => defined($k) ? constant($k) : null,
      ["FILES_ACCESS_TOKEN", "VIP_ENABLE_VIP_SEARCH", "VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION"]));
  ' "$source" "$TEST_ROOT/wp/" "$token" 2> "$TEST_ROOT/php-errors"; then
    cat "$TEST_ROOT/php-errors" >&2
    exit 1
  fi
  if [ -s "$TEST_ROOT/php-errors" ]; then cat "$TEST_ROOT/php-errors" >&2; exit 1; fi
}

mailpit() {
  enabled=$1; shift
  run_script php-fpm/rootfs/usr/local/bin/run.sh "$@"
  marker mailpit.enabled "$enabled"
  cases=$((cases + 1))
}
mailpit 1 VIP_DEVENV_MAILPIT=1
mailpit 0 VIP_DEVENV_MAILPIT=0 "LANDO_INFO=$LANDO"
mailpit 1 "LANDO_INFO=$LANDO"
mailpit 0

photon() {
  expected=$1; configured=$2; shift 2
  values=$(constants "$ROOT/wordpress/dev-tools/wp-config-defaults.php" "$configured" "$@")
  actual=$(printf '%s' "$values" | jq -c '.[0]')
  expect "$expected" "$actual" 'Photon token'
  cases=$((cases + 1))
}
photon '"local-dev-token"' '' VIP_DEVENV_PHOTON=1
photon null '' VIP_DEVENV_PHOTON=0 "LANDO_INFO=$LANDO"
photon '"local-dev-token"' '' "LANDO_INFO=$LANDO"
photon null '' 'LANDO_INFO={"photon":{"healthy":false}}'
photon null ''
photon '"custom"' custom VIP_DEVENV_PHOTON=1 "LANDO_INFO=$LANDO"

search() {
  existing=$1; enabled=$2; ready=$3; shift 3
  printf '<?php\n' > "$TEST_ROOT/wp/config/wp-config.php"
  rm -f "$TEST_ROOT/installed" "$TEST_ROOT/indexed" "$TEST_ROOT/es-ready"
  if [ "$existing" = 1 ]; then touch "$TEST_ROOT/installed"; fi
  run_script wordpress/dev-tools/setup.sh "$@"
  values=$(constants "$TEST_ROOT/wp/config/wp-config.php" '' "$@")
  actual=$(printf '%s' "$values" | jq -c '.[1:]')
  if [ "$enabled" = 1 ]; then expect '[true,true]' "$actual" 'Search constants';
  else expect '[null,null]' "$actual" 'Search constants'; fi
  marker indexed "$enabled"
  marker es-ready "$ready"
  cases=$((cases + 1))
}
search 0 1 1 VIP_DEVENV_ELASTICSEARCH=1 VIP_DEVENV_DEMO_APP=1
search 0 0 0 VIP_DEVENV_ELASTICSEARCH=0 ENABLE_ELASTICSEARCH=1 "LANDO_INFO=$LANDO"
search 0 0 1 VIP_DEVENV_ELASTICSEARCH=1 VIP_DEVENV_DEMO_APP=0 "LANDO_INFO=$LANDO"
search 0 0 1 VIP_DEVENV_ELASTICSEARCH=1
search 0 1 1 "LANDO_INFO=$LANDO"
search 1 0 1 VIP_DEVENV_ELASTICSEARCH=1 VIP_DEVENV_DEMO_APP=1
search 0 0 1 ENABLE_ELASTICSEARCH=1

printf 'PASS: %s service scenarios\n' "$cases"
