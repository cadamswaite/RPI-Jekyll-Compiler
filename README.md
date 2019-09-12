# SecurePi
Secures a Raspberry Pi ssh connection from most attacks using UFW, fail2ban and public key auth.

## It is important the RPi is not accessible from the internet when setting up ssh!
Usually this would be blocked by your router firewall. If not, the RPI could be hacked within minutes of connecting!
To avoid this, at least change the default password of the pi using:
```
passwd
```

Additional steps would be to change the username as well, change the port of ssh etc.This is mainly important during setup. 
Once public key auth is setup (along with ufw rate limits and fail2ban to block repeat offenders) the pi *should*<sup>TM</sup> be secure.

## Prerequisites
On Windows, need putty, puttygen and pageant to manage certificates. All can be found [here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).

## Steps
1. Burn latest [rasbian buster light](https://www.raspberrypi.org/downloads/raspbian/)  onto SD card.
2. Download and run the install script using 
```
wget https://raw.githubusercontent.com/cadamswaite/SecurePi/master/install.sh
sudo bash install.sh
```
3. When terminal outputs "SSH key generated. Please copy id_rsa to PC now"
run in the command terminal (CMD)
```
scp pi@<PI IP ADDRESS>:~/.ssh/id_rsa C:\Users\<UserName>\Desktop\
```
4. Import the key into PuttyGen
5. Export the private key as a .ppk
6. Open the .ppk with pageant
7. Initiate a putty connection to the pi. This should not require a password.
8. Press enter in the Pi terminal. This disables password entry, allowing for public key auth only.
9. At this point, the Pi should be protected from most attacks.
