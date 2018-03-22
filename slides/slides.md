% title: SSH for fun and profit
% subtitle: or how I learned to love the shell
% author: Steven Hollingsworth
% author: Lead SRE - Barracuda Networks
% thankyou: Thanks everyone!
% thankyou_details: Special thanks to:
% contact: <a href="http://www.barracudanetworks.com/">Barracuda Networks</a>
% contact: <a href="https://rootaccess.space">Root Access</a>
% favicon: figures/favicon.ico

---
title: Welcome!
subtitle: Here is what we'll cover...
build_lists: true

- background / history
- running/configuring a secure sshd instance
- ssh keys: and why you should use these whenever possible
- ssh agent
- common uses:  `ssh, rsync, scp`
- all things port forwarding
- tips and tricks


---
title: sshd Background and History
class: img-top-center

* overview / [Wikipedia]( https://en.wikipedia.org/wiki/Secure_Shell )
* ssh-1 - 1995 / [SSH Communications Security](https://en.wikipedia.org/wiki/SSH_Communications_Security) initial release
* ssh-2 - 2006 / IETF made a new RFC [4253](https://tools.ietf.org/html/rfc4253) for cross compatibility with ssh-1
* OpenSSH - 1999 / The OpenBSD team made an [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) - current stable is v7.6

We'll be using OpenSSH exclusively in this demo as that's the standard for most OS's you'll see in the wild.

---
title: Interactive playground
subtitle: don't be a jerk :-P
class: img-top-center

* As we go through the slide deck, feel free to poke at a server I've put into the rootaccess slack channel `#linux`
* to add new users on server I'll give you sudo, and use
    * `/usr/local/bin/add_user_key.sh`
* If you want a shell to test with paste your `public` key (we'll go over that shortly) into the chat window with your desired username and someone will set it up!

---
title: Securing SSH Server (sshd)
subtitle: important if you are exposing sshd to the interwebs
class: segue dark nobackground


---
title: prerequisites
class: img-top-center

# Installation
* Ubuntu/Linux - Usually Default installed 
    *  `apt get install openssh`
* Windows 
    * [Putty](https://www.putty.org/)
    * ? something better
* Mac - Default Installed

---
title: /etc/ssh/sshd_config
class: img-top-center

* Example config: [sshd_config](https://raw.githubusercontent.com/shollingsworth/ssh_is_cool/master/sshd_config_example.txt)
<pre class="prettyprint" data-lang="/etc/ssh/sshd_config">
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
<b>AllowGroups allow_ssh</b>
UsePrivilegeSeparation yes
<b>PasswordAuthentication no</b>
ChallengeResponseAuthentication no
KeyRegenerationInterval 3600
ServerKeyBits 2048
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
<b>PermitRootLogin no</b>
<b>StrictModes yes</b>
RSAAuthentication yes
... (cont)
</pre>

---
title: /etc/ssh/sshd_config (cont.)
class: img-top-center

<pre class="prettyprint" data-lang="/etc/ssh/sshd_config">
<b>PubkeyAuthentication yes</b>
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
<b>PermitEmptyPasswords no</b>
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
</pre>

---
title: gotchas / applying changes
class: img-top-center

* be careful you can lock yourself out
    * especially if you're using HaaS like AWS which has no actual console
    * usually if you already have a session open, you can test with another shell
* after editing, issue the command `/etc/init.d/sshd`
    * you can do this without fear of the shell dropping (unless something is really wonky and sshd segfaults)


---
class: img-top-center

## DEMO - sshd changes
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />


---
title: ssh keys
subtitle: a.k.a passwords suck, use keys instead
class: segue dark nobackground

---
title: key exchange overview
class: img-top-center

<img height=360 src=figures/key_based_2.png />

<footer class="source">
<b>Source:</b>https://www.vmcentral.com.au/how-to-configure-ssh-to-accept-only-key-based-authentication/
</footer>

---
title: generating your first ssh key
class: img-top-center

* Interactive
    * `ssh-keygen`
* more specific
    * `ssh-keygen -b 2048 -t ed25519 -f ~/.ssh/testing`

---
title: generating your first ssh key (cont.)
class: img-top-center

<pre class="prettyprint" data-lang="sample output">
ssh-keygen -b 2048 -t ed25519 -f ~/.ssh/testing
...
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
<b>
Your identification has been saved in /home/shollingsworth/.ssh/testing.
Your public key has been saved in /home/shollingsworth/.ssh/testing.pub.
</b>
The key fingerprint is:
SHA256:tS22gJLKRyjGb0ubdzmX/vgM8brnhKJjjHVpJ4yTatA shollingsworth@shollingsworth-lnx
The key's randomart image is:
+--[ED25519 256]--+
|                 |
|                 |
|          .      |
|.  . . . . o     |
|.oo + = S.+ .    |
|.+.E * * ++o     |
|  ++* +.+ooo     |
|  o=+=.+.o*.     |
|  .+o.o +=*=     |
+----[SHA256]-----+
</pre>

---
title: a note on passphrases
class: img-top-center

* Passphrases are important, especially if it's your main SSH key.
* Make sure it's a passphrase (i.e. _*&gt;12 characters*_) 
    * "`Grandma 2 Likes #! Gremlins 55`"
    * We can talk more about what makes a good password if we have time at the end
* Sometimes having a non-passphrased key is useful as well, such as using a key to run backup jobs via `rsync`

---
title: ssh agent
subtitle: or not going insane by typing in my passphrase a gazillion times
class: segue dark nobackground

---
title: starting the agent
subtitle: simple example
class: img-top-center

### note - *you'll have to run this once, see next page for bashrc example*
<br>

<pre class="prettyprint" data-lang="~/.bashrc snippet">
export SSH_AUTH_SOCK="${HOME}/.ssh/SSH_AGENT_SOCK"
rm -f ${SSH_AUTH_SOCK}
ssh-agent -a ${SSH_AUTH_SOCK}
</pre>

---
title: starting the agent 
subtitle: more complex example in ~/.bashrc
class: img-top-center

<pre class="prettyprint" data-lang="~/.bashrc snippet">
sshkeys=()
<b>sshkeys+=(~/.ssh/testing)</b>
sshkeys+=(~/.ssh/key1.pem)
sshkeys+=(~/.ssh/key2.pem)

export SSH_AUTH_SOCK="${HOME}/.ssh/SSH_AGENT_SOCK"
<b>if ! ssh-add -l | grep -q testing; then</b>
   rm -f ${SSH_AUTH_SOCK}
   ssh-agent -a ${SSH_AUTH_SOCK}
   sleep 1
   for i in ${sshkeys[@]}; do
    <b>ssh-add ${i}</b>
   done
fi
</pre>

---
title: gotchas / tips
subtitle: more complex example in ~/.bashrc
class: img-top-center

* see what keys are loaded: `ssh-add -l`
* kill all your keys: `ssh-add -D`

Gotchas:

* there's a known limitation to the number of keys you can stuff via `ssh-add`


---
class: img-top-center

## DEMO - ssh-agent
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: ~/.ssh/config
subtitle: or how to sanely manage hosts I connect to regularly
class: segue dark nobackground

---
title: ~/.ssh/config
subtitle: global settings

<pre class="prettyprint" data-lang="~/.ssh/config">
Host *
    CheckHostIP yes
    User shollingsworth
    <b>IdentityFile ~/.ssh/testing</b>
    IdentitiesOnly yes
</pre>

---
title: ~/.ssh/config
subtitle: wildcard grouping a trusted server set

<pre class="prettyprint" data-lang="~/.ssh/config">
Host *.trusted.com
    ForwardAgent yes
</pre>

---
title: ~/.ssh/config
subtitle: host specific setting / shortcut

<pre class="prettyprint" data-lang="~/.ssh/config">
Host demo
    HostName 54.219.154.10
    User ubuntu
    <b>DynamicForward 9999
    LocalForward 7777 127.0.0.1:9200</b>
</pre>

---
class: img-top-center

## DEMO
# using ~/.ssh/config
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: common SSH uses
subtitle: there are many
class: segue dark nobackground

---
title: ssh

* normal shell
    * `ssh user@remote.host.com` 
* executing a command non interactively
    * `ssh user@remote.host.com "hostname"`

---
title: rsync / scp
subtitle: beware of the forward slash on source

* copy from local to remote
    * `rsync -av slides demo:~/`
    * `scp -r slides demo:~/`
* copy from remote to local
    * `rsync demo:~/slides -av /tmp`
    * `scp -r demo:~/slides /tmp`


---
title: other uses
subtitle: but wait... there's more!

* tar over ssh (emergency backup)
    * `tar -cjf - slides | ssh demo "cat - > ~/slides.tbz"`
* I've also uses it with a ddrescue variant to pipe an image to a remote server for forensic recovery using the same type of method

---
class: img-top-center

## DEMO - ssh commands
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: local/remote/dynamic port forwarding
subtitle: one of the coolest features of ssh
class: segue dark nobackground

---
title: local port forwarding
subtitle: i drink your milkshake
class: img-top-center

# forward remote mysql connection to local

* via ssh 
    * `ssh -L 127.0.0.1:7777:127.0.0.1:3306 demo`
* via ~/.ssh/config
    * `LocalForward 7777 127.0.0.1:3306`
* PoC
    * `mysql --host=127.0.0.1 -P 7777 --user=root -p`

---
class: img-top-center

## DEMO - local port forwarding
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: remote port forwarding
subtitle: you drink my milkshake (I guess)
class: img-top-center

# setup a local webserver on 8000, access via remote

* setup local listener 
    * don't run this inside a directory you care about! 
    * `python -m SimpleHTTPServer 8000`
* via ssh 
    * `ssh -R 7777:127.0.0.1:8000 demo`
* via ~/.ssh/config
    * `RemoteForward 7777 127.0.0.1:8000`

---
title: remote port forwarding (cont.)
class: img-top-center

* PoC (on remote)
    * `curl localhost:7777`

---
class: img-top-center

## DEMO - remote port forwarding
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: dynamic port forwarding
subtitle: stealing a servers identity (or ip address)
class: img-top-center

* via ssh 
    * `ssh -D 7777 demo`
* via ~/.ssh/config
    * `DynamicForward 7777`
* PoC
    * Demo  with firefox and adding a socks5a proxy to `127.0.0.1:7777`

---
class: img-top-center

## DEMO - dynamic port fowarding
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: forwarding on already connected ssh session
class: img-top-center

* magic key sequence is `~C` (tilde then capital c)

<pre class="prettyprint" data-lang="~C demo">
ubuntu@ip-172-31-10-5:~$ 
ssh> -L 7777:127.0.0.1:3306
</pre>

---
class: img-top-center

## DEMO "~C" ssh command
<br>
<br>
<br>
<br>
<br>
<br>
<img height=300 src=./figures/peanut_butter_jelly.gif />

---
title: Questions and other stuff
subtitle: feel free to speak up!
class: img-top-center

- volunteers for demoing using ssh on a windows box?
- ssh vpn tunnel?

Misc:

- created with [slidedeck](https://github.com/rmcgibbo/slidedeck)
- this github repo [shollingsworth/ssh_is_cool](https://github.com/shollingsworth/ssh_is_cool)
