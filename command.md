sudo apt update
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.0.tar.xz
tar -xvf linux-6.15.0.tar.xz
cd linux-6.15.0
make defconfig 
make -j$(nproc)
make modules
make modules_install

sudo make install

