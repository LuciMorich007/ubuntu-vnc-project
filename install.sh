#!/data/data/com.termux/files/usr/bin/bash

# ၁။ လိုအပ်သော Packages များ သွင်းခြင်း
echo "[*] System ကို ပြင်ဆင်နေသည်..."
pkg update -y && pkg upgrade -y
pkg install proot-distro wget -y

# ၂။ အဟောင်းများကို လုံးဝအမြစ်ပြတ်ရှင်းထုတ်ခြင်း
echo "[*] နေရာလွတ်များ ရှင်းလင်းနေသည်..."
proot-distro remove ubuntu 2>/dev/null
rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu
mkdir -p $PREFIX/var/lib/proot-distro/cache

# ၃။ Ubuntu Rootfs ကို GitHub မှ ဒေါင်းလုဒ်ဆွဲခြင်း
echo "[*] Ubuntu Image ကို ဒေါင်းလုဒ်ဆွဲနေသည်..."
URL="https://github.com/LuciMorich007/ubuntu-vnc-project/releases/download/v1.0/ubuntu-22.04-server-cloudimg-arm64-root.tar.xz"
wget -O $PREFIX/var/lib/proot-distro/cache/ubuntu.tar.xz "$URL"

# ၄။ Proot-distro ကို အသုံးပြု၍ Manual သွင်းခြင်း (Local File Method)
echo "[*] Ubuntu ကို Extract လုပ်နေသည် (ခေတ္တစောင့်ပါ)..."
# ဤနေရာတွင် PD_OVERRIDE_TARBALL_URL မသုံးဘဲ manual path ဖြင့် သွင်းပါမည်
proot-distro install ubuntu --override-alias ubuntu

# ၅။ GUI (XFCE4) နှင့် VNC Setup Script ဖန်တီးခြင်း
echo "[*] Desktop Environment အတွက် ပြင်ဆင်နေသည်..."
# Ubuntu ထဲက root folder ထဲမှာ setup script သွားရေးပါမယ်
ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
cat <<EOF > $ROOTFS/root/setup_vnc.sh
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
echo "[*] Ubuntu အတွင်းပိုင်း၌ GUI ကို သွင်းနေသည်..."
proot-distro login ubuntu -- bash /root/setup_vnc.sh

# ၇။ Shortcut ပြုလုပ်ခြင်း
echo "proot-distro login ubuntu" > $PREFIX/bin/start-ubuntu
chmod +x $PREFIX/bin/start-ubuntu

echo "------------------------------------------"
echo "   အောင်မြင်စွာ ပြီးစီးပါပြီ!   "
echo "   Command: start-ubuntu   "
echo "------------------------------------------"
