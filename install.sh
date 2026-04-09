#!/data/data/com.termux/files/usr/bin/bash

# ၁။ လိုအပ်သော Packages များ သွင်းခြင်း
echo "[*] System ကို ပြင်ဆင်နေသည်..."
pkg update -y && pkg upgrade -y
pkg install proot-distro wget tar -y

# ၂။ အရင်က ရှိခဲ့သမျှ Ubuntu Folder များကို အကုန်ရှင်းထုတ်ခြင်း
echo "[*] အဟောင်းများကို ရှင်းလင်းနေသည်..."
proot-distro remove ubuntu 2>/dev/null
rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu

# ၃။ Ubuntu Rootfs ကို Manual ဆွဲယူပြီး ဖြည်ချခြင်း
echo "[*] Ubuntu Image ကို ဒေါင်းလုဒ်ဆွဲပြီး Extract လုပ်နေသည်..."
mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu
URL="https://github.com/LuciMorich007/ubuntu-vnc-project/releases/download/v1.0/ubuntu-22.04-server-cloudimg-arm64-root.tar.xz"

# ဒေါင်းလုဒ်ဆွဲပြီး တိုက်ရိုက် ဖြည်ချပါမည် (ပိုမြန်ပြီး Error ကင်းပါသည်)
wget -qO- "$URL" | tar -xJf - -C $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu --strip-components=0 2>/dev/null

# ၄။ Proot-distro စာရင်းထဲဝင်အောင် Configuration File လုပ်ခြင်း
mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/etc
echo "nameserver 8.8.8.8" > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/etc/resolv.conf

# ၅။ GUI (XFCE4) နှင့် VNC အတွက် Setup Script ရေးသားခြင်း
echo "[*] Desktop Environment အတွက် ပြင်ဆင်နေသည်..."
cat <<EOF > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/setup_vnc.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update
apt install xfce4 xfce4-goodies tightvncserver dbus-x11 -y
mkdir -p ~/.vnc
echo "#!/bin/bash
export DISPLAY=:1
startxfce4 &" > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup
EOF

# ၆။ Ubuntu ထဲသို့ဝင်၍ GUI သွင်းခြင်း
echo "[*] Ubuntu အတွင်းပိုင်း၌ GUI ကို သွင်းနေသည် (၅ မိနစ်ခန့် ကြာနိုင်သည်)..."
proot-distro login ubuntu -- bash /root/setup_vnc.sh

# ၇။ Shortcut ပြုလုပ်ခြင်း
echo "proot-distro login ubuntu" > $PREFIX/bin/start-ubuntu
chmod +x $PREFIX/bin/start-ubuntu

echo "------------------------------------------"
echo "   အောင်မြင်စွာ ပြီးစီးပါပြီ! (Version 5)   "
echo "   Command: start-ubuntu   "
echo "------------------------------------------"
