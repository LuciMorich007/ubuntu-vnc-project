#!/data/data/com.termux/files/usr/bin/bash

# ၁။ လိုအပ်သော Packages များ သွင်းခြင်း
echo "[*] Termux environment ကို ပြင်ဆင်နေသည်..."
pkg update -y && pkg upgrade -y
pkg install proot-distro wget -y

# ၂။ Ubuntu OS ကို သင့် GitHub မှ တိုက်ရိုက် Install လုပ်ခြင်း
UBUNTU_URL="https://github.com/LuciMorich007/ubuntu-vnc-project/releases/download/v1.0/ubuntu-22.04-server-cloudimg-arm64-root.tar.xz"

echo "[*] Ubuntu OS ကို GitHub မှ Download ဆွဲပြီး Install လုပ်နေသည်..."
echo "[*] ဖိုင်ဆိုဒ်ကြီးသဖြင့် ခေတ္တစောင့်ဆိုင်းပေးပါ..."
proot-distro install ubuntu --url $UBUNTU_URL

# ၃။ Ubuntu ထဲမှာ GUI (XFCE4) နှင့် VNC သွင်းရန် Script ကို ကြိုတင်ဖန်တီးခြင်း
echo "[*] Desktop Environment (XFCE4) နှင့် VNC Server အတွက် ပြင်ဆင်နေသည်..."
cat <<EOF > $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu/root/setup_vnc.sh
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update
echo "[*] GUI အတွက် လိုအပ်သော ဖိုင်များကို Install လုပ်နေသည် (၅ မိနစ်ခန့် ကြာနိုင်သည်)..."
apt install xfce4 xfce4-goodies tightvncserver dbus-x11 -y

# VNC Startup Config ပြုလုပ်ခြင်း
mkdir -p ~/.vnc
echo "#!/bin/bash
export DISPLAY=:1
startxfce4 &" > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "[*] GUI Setup ပြီးစီးပါပြီ!"
EOF

# ၄။ Ubuntu ထဲသို့ တစ်ခါတည်းဝင်၍ GUI သွင်းခိုင်းခြင်း
echo "[*] Ubuntu အတွင်းပိုင်းထဲသို့ဝင်၍ GUI Install လုပ်ငန်းစဉ် စတင်နေသည်..."
proot-distro login ubuntu -- bash /root/setup_vnc.sh

# ၅။ နောက်တစ်ခါ ပြန်ဝင်ရလွယ်အောင် Shortcut ပြုလုပ်ခြင်း
echo "proot-distro login ubuntu" > $PREFIX/bin/start-ubuntu
chmod +x $PREFIX/bin/start-ubuntu

echo ""
echo "------------------------------------------"
echo "   INSTALLATION COMPLETE (အားလုံးပြီးပါပြီ)   "
echo "------------------------------------------"
echo "၁။ Ubuntu ထဲဝင်ရန်: start-ubuntu ဟုရိုက်ပါ။"
echo "၂။ Desktop ဖွင့်ရန်: vncserver :1 ဟုရိုက်ပါ။"
echo "   (ပထမဆုံးအကြိမ်တွင် Password ၆ လုံး ပေးရပါမည်)"
echo "၃။ Android VNC Viewer app မှ localhost:1 ဖြင့် ချိတ်ဆက်ပါ။"
echo "------------------------------------------"
