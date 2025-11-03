#!/bin/bash
set -e
echo "=== Actualizando sistema ==="
apt update -y && apt upgrade -y

echo "=== Instalando entorno gráfico y XRDP ==="
apt install -y lxqt-core xorg openbox lightdm htop xrdp

echo "=== Configurando /etc/skel para futuras cuentas ==="
echo "lxqt-session" > /etc/skel/.xsession
chmod +x /etc/skel/.xsession

echo "=== Creando usuario 'esteban' ==="
if ! id "esteban" &>/dev/null; then
    adduser --gecos "" esteban
    usermod -aG sudo esteban
fi

echo "=== Configurando XRDP ==="
systemctl enable xrdp
systemctl restart xrdp

echo "=== Desactivando LightDM (solo RDP) ==="
systemctl stop lightdm || true
systemctl disable lightdm || true

echo "=== Configurando inicio LXQt en XRDP ==="
cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak
cat << 'EOF' > /etc/xrdp/startwm.sh
#!/bin/sh
if test -r /etc/profile; then
    . /etc/profile
fi
if test -r ~/.profile; then
    . ~/.profile
fi
export DESKTOP_SESSION=lxqt
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=LXQt
exec startlxqt
EOF
chmod +x /etc/xrdp/startwm.sh

echo "=== Limpiando y reiniciando ==="
apt autoremove -y && apt clean
reboot
