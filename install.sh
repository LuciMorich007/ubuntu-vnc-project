#!/data/data/com.termux/files/usr/bin/bash

# ၁။ လိုအပ်သော Packages များ သွင်းခြင်း
echo "[*] Termux system ကို ပြင်ဆင်နေသည်..."
pkg update -y && pkg upgrade -y
pkg install proot-distro wget -y

# ၂။ အရင်က ရှိနေသော Ubuntu အဟောင်းများကို အကုန်ရှင်းထုတ်ခြင်း
echo "[*] အဟောင်းများကို ရှင်းလင်းနေသည်..."
proot-distro remove ubuntu 2>/dev/null
rm -rf $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu
proot-distro clear-cache

# ၃။ Ubuntu OS ကို GitHub မှ Manual ဒေါင်းလုဒ်ဆွဲခြင်း
echo "[*] Ubuntu Image ကို ဒေါင်းလုဒ်ဆွဲနေသည်..."
URL="https://github.com/LuciMorich007/ubuntu-vnc-project/releases/download/v1.0/ubuntu-22.04-server-cloudimg-arm64-root.tar.xz"
wget $URL -O $PREFIX/var/lib/proot-distro/cache/ubuntu.tar.xz

# ၄။ ဒေါင်းလုဒ်ရလာသော ဖိုင်ကို အသုံးပြု၍ Install လုပ်ခြင်း
echo "[*] Ubuntu ကို စတင် Install လုပ်နေသည်..."
export PD_OVERRIDE_TARBALL_URL="file://$PREFIX/var/lib/proot-distro/cache/ubuntu.tar.xz"
export PD_OVERRIDE_TARBALL_STRIP_OPT=0
proot-distro install ubuntu

# ၅။ GUI (XFCE4) နှင့် VNC အတွက် Script ကို ဖန်တီးခြင်း
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
echo "[*] GUI Setup ပြီးစီးပါပြီ!"
EOF

# ၆။ Ubuntu ထဲသို့ဝင်၍ GUI သွင်းခြင်း
echo "[*] Ubuntu ထဲသို့ဝင်၍ GUI သွင်းနေသည် (၅ မိနစ်ခန့် ကြာနိုင်သည်)..."
proot-distro login ubuntu -- bash /root/setup_vnc.sh

# ၇။ Shortcut Command ပြုလုပ်ခြင်း
echo "proot-distro login ubuntu" > $PREFIX/bin/start-ubuntu
chmod +x $PREFIX/bin/start-ubuntu

# ၈။ ယာယီဖိုင်ကို ပြန်ဖျက်ခြင်း
rm $PREFIX/var/lib/proot-distro/cache/ubuntu.tar.xz

echo "------------------------------------------"
echo "   အားလုံး ပြီးစီးပါပြီ (SUCCESS!)   "
echo "------------------------------------------"
echo "၁။ Ubuntu ထဲဝင်ရန်: start-ubuntu"
echo "၂။ Desktop ဖွင့်ရန်: vncserver :1"
echo "------------------------------------------"
