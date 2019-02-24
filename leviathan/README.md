# leviathan

walkthrough for [leviathan](http://overthewire.org/wargames/leviathan/).

I recommend you do these yourself. If you are stuck, feel free to snoop around
this file. However, to keep the game spirit, the passwords are in the
`00_passwords.txt` file. **Don't go through that file unless you want to jump to
any given level.**

Since this requires a lot of `ssh`ing around, I added a `jump` script that
automates that. As long as `leviathan<level>: <password>` is set in the
`00_passwords.txt` file, it will ssh into the correct user in the remote server
by running `./jump <level>`. This depends on installing `expect`, though.

## leviathan0

Before starting the level do:

```bash
echo "leviathan0: leviathan0" > 00_passwords.txt
./jump 0
```

and you should be able to ssh into the server automagically.

The first thing we do is `ls`. Since there is no output, `ls -al` and we find a
`.backup` directory. `ls .backup` will give us a `bookmarks.html` file.

It seemed to be a longshot but apparently
`grep "password" .backup/bookmarks.html` really is the wait to go, for some
reason. That's it, we got the first password. Add it as `leviathan1: <password>`
to the `00_passwords.txt` file.
