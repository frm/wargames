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


## leviathan1

We find a `check` executable. Running it, it prompts for a password.

My first inclination is to try `strings`. `strings` is a program that prints all
strings it finds in a file, whether or not it is binary.

By doing `strings ./check`, the string `love` catches my eye. Trying that gives
out... no result.

We need to figure out what is happening with the binary behind the scenes. The
fastest way to do that is through `ltrace`. `ltrace` prints out the calls that
are performed by a programming during live execution.

```c
leviathan1@leviathan:~$ ltrace ./check
__libc_start_main(0x804853b, 1, 0xffffd784, 0x8048610 <unfinished ...>
printf("password: ")                                            = 10
getchar(1, 0, 0x65766f6c, 0x646f6700password: test
)                           = 116
getchar(1, 0, 0x65766f6c, 0x646f6700)                           = 101
getchar(1, 0, 0x65766f6c, 0x646f6700)                           = 115
strcmp("tes", "sex")                                            = 1
puts("Wrong password, Good Bye ..."Wrong password, Good Bye ...
)                            = 29
+++ exited (status 0) +++
```

Bingo, `sex` is hardcoded into the program, in the comparison. Inputting that
password gives us a shell we can use. Frankly this shell is barely usable, no
autocomplete, nothing. Calling `/bin/bash` does the trick.

Now we can retrieve the password which should be done with `cat
/etc/leviathan_pass/leviathan2`.

