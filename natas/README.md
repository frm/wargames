# natas

Walkthrough [Natas](http://overthewire.org/wargames/natas/).

I recommend you do these yourself. If you are stuck, feel free to snoop around
this file. However, to keep the game spirit, the passwords are in the
`00_passwords.txt` file. **Don't go through that file unless you want to jump to
any given level.**

## natas0

right click, inspect, the password is in an html comment

## natas1

either open the page with the console already open or use a keyboard shortcut.

the password is still an html comment.

## natas2

inspecting the html reveals the existence of a `files` directory. If you go
`/files`, you will find a `users.txt` file with the `natas3` password in plain
text.

## natas3

inspecting the html, you will find a comment saying that not even google will
find the file this time. this is a hint to open the `/robots.txt` file.

opening it reveals that a `/s3cr3t` directory exists, which we can access and
see that a `users.txt` file exists. it contains our password.

## natas4

the page has a text saying you have arrived from a previous page. the only page
allowed is natas5. this is the referer header.

if you go to `natas5.natas.labs.overthewire.org`, click "cancel" when prompted
for password, then change the url to `natas4`, it should still not allow you
because changing the url does not set the http referer header.

there are two ways to do this: manually setting the header in the http request
and playing around with javascript to do that for us.

the first you can achieve by running this in your terminal:

```bash
# don't forget to replace $NATAS4_PASSWORD with the password you got
# from the previous step
curl --referer http://natas5.natas.labs.overthewire.org/ \
  natas4:$NATAS4_PASSWORD@natas4.natas.labs.overthewire.org
```

the response will contain the password

the second you can achieve by doing the following:

1. go to `natas5.natas.labs.overthewire.org`
2. click "cancel" when prompted for password
3. open the browser console
4. type `location.href = "http://natas4.natas.labs.overthewire.org"`

this will change the location of the page and the browser will set the correct
http header. the natas4 page should now display the password.

i used the second method because i was lazy. when i came back to do this write
up, i did the first method.

## natas5

apparently we are not logged in. opening the console allows us to see the cookie (just type `document.cookie`).

if we set it to `loggedin=1` and refresh (`document.cookie = "loggedin=1"`), it
should give us the password.

## natas6

if you click "view source" you can find that the php code is comparing against a
value obtain from a `/includes/secret.inc` file.

by putting that into the address bar, we can find the secret. now we just need
to go back input that secret into the form. it will spit out the password.

## natas7

by checking the html, there is a comment saying the password is in
`/etc/natas_webpass/natas8`. if we try to access that page through the browser
it will error because we don't have access to it.

however, going back and clicking the 'home' and 'about' links in the main page
we can notice they don't redirect. instead they use php to fetch the contents of
the page html document.

we can instead use that by changing the `page` url parameter to
`/etc/natas_webpass/natas8`.

## natas8

clicking "view source" we can see that we now have an encoded secret and the
script encodes the input value to compare with the encoded secret.

we can just reverse the encoded secret by typing into a php interpreter:

```php
// don't forget to replace $encoded_secret by the actual encoded secret string
echo base64_decode(strrev(hex2bin($encoded_secret)));
```

then it's just a matter of pasting the result into the input in the natas8 page
and getting the password.

## natas9

by clicking "view source code", we can see that the php script is running grep
and we can inject shell code into this. to try it:

```bash
"" ls; #
```

it will output the files in the current directory. going back to natas7, we get
the idea of checking the contents of `/etc/natas_webpass/natas10`:

```bash
""; cat /etc/natas_webpass/natas10 #
```

and we will have access to the password.

## natas10

looking through the source code of the php script, we can now see that it will
not allow certain characters. to get around this, we will just play around with
grep options and search for anything in a set of files. input this into the form

```bash
-e ".*" /etc/natas_webpass/natas11 #
```

this will search for any set of characters in the `/etc/natas_webpass/natas11`
file and ignore the rest of the command.

the password will be there in plaintext.
