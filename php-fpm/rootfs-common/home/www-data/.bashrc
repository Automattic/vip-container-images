cat /etc/vip-motd

echo "You're using interactive shell for $LANDO_APP_NAME"
echo ""
echo ""
PS1='\[\033[01;32m\]\u\[\033[01;34m\]:\w \$\[\033[00m\] '