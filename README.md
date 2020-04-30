# Simple RouterBOARD backup tool

## How to install it on your own environment

- Fork this repo to your GitHub account (use private repo in usual case or
    public if you want to show your credentials to the world).

- Clone your forked repo to NOC host (or any machine inside your network which
    can act like a network operational center).

- Generate new ssh key for special backup user which will deal with saving
    backups: `ssh-keygen -f .ssh/id_rsa -q -N ""`

- Optional: encrypt it using [SOPS](https://github.com/mozilla/sops): `sops -e
    .ssh/id_rsa > .ssh/id_rsa.sops` and then delete original key `rm .ssh/id_rsa`

- Add your routers line-by-line to `routers.txt` list. I prefer to use DNS names
    rather IP addresses in form `router-N.location.mydomain.com`.

- Add keys and configuration to git repo `git add && git commit -m "Configure"`

- Run `./addruser.sh` to add `routerbkp` and its ssh key to all routers

- Run `./do_backup.sh` to make sure that everything will work automatically.
    Check `git log` to see commits with full routers configuration.

- Add `do_backup.sh `as cron job or systemd timer (see hints below). Check later
    that eventually configuration changes will appear in your GitHub repository.

## Add systemd timer

```sh
mkdir -pv ~/.config/systemd/user/
cp timers/routerbkp.* ~/.config/systemd/user/
systemctl --user enable routerbkp.timer
systemctl --user start routerbkp.timer
systemctl list-timers --all --user
```
