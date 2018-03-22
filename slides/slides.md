% title: SSH for fun and profit
% subtitle: or just getting sh*t done 
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
% build_lists: true

- background / history
- running/configuring a secure sshd instance
- ssh keys: and why you should use these whenever possible
- ssh agent
- common uses:  `ssh, rsync, scp`
- dymanic port forwarding: `socks5a proxy`
- local port fowarding 
- remote port forwarding

---
title: Welcome! - continue
subtitle: we may also cover if we have time...
% build_lists: true

- tips and tricks
- volunteers for demoing using ssh on a windows box?
- ssh vpn tunnel?

---
title: sshd Background and History
class: img-top-center

* overview - [Wikipedia]( https://en.wikipedia.org/wiki/Secure_Shell )
* ssh-1 - 1995 - [SSH Communications Security](https://en.wikipedia.org/wiki/SSH_Communications_Security) initial release
* ssh-2 - 2006 - IETF made a new RFC [4253](https://tools.ietf.org/html/rfc4253) for cross compatibility with ssh-1
* OpenSSH - 1999 - The OpenBSD team made an [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) - current stable is v7.6

We'll be using OpenSSH exclusively in this demo as that's the standard for most OS's you'll see in the wild.

---
title: securing sshd 
subtitle: prerequisites
class: img-top-center

---
title: securing sshd 
subtitle: /etc/ssh/sshd_config
class: img-top-center

_*important if you are exposing sshd to the interwebs*_
