# Opi9 API #

**BASE URL :**https://quiet-reef-36650.herokuapp.com


**LOGIN :**

### GET (/users/signin.json)###


***Headers*** :

Content-Type = application/json


***Query Params*** 

email = niranjan@gmail.com
password = 1




***Response*** :

***Success*** :

```
#!json


{
  "accesstoken": "FQoDYXdzEO3//////////wEaDO7q0/WPrOIys9PcjSKrARPFP0B60rV6Zj2Q/tduUk0MIB2toOVZy2aJ13nYPA0LhTlb8qJe8WyY5W0nnD1SmWIf29F4ZKiP/04ITErNVMt0Eoq6seYN698Z78F6/ejjxDn9uOO6QHAYsO0yS2U0PDd7emNzS6T2j7ymTFrWURqkHPKayJhe80vA7MyFP8V4pCPvI0SsFaKtq4YKbOx79AyTw8DNFxHVL/sDp+btXGjp8mCqe/DVf9jQGSij5OXBBQ==",
"user": {
    "lastname": "l",
    "firstname": "niranjan",
    "password": "1",
    "phone": "7890123456",
    "email": "niranjan@gmail.com",
    "connected_user": [
      "test@test.com",
      "rajesh@gmail.com",
      "kvana@gmail.com",
      "aditkvana@gmail.com"
    ],
    "gender": "male",
    "usertypereg": "no"
  },
  "status": "success"
}
```
***Failure*** :

```
#!json

{
  "error": "invalid password",
  "status": "error"
}
```
** SIGNUP: **

### POST (/users/signup.json) ###

***Headers*** :

Content-Type = application/json

***Body***

   firstname=new
   lastname=user
   email=user@new.com
   password=1234
   password_confirmation = 1234
   phone=890765478
   usertypereg=yes/no
   gender=male/female


***Response***:

***Success***:
```
#!json
{
  "accesstoken": "FQoDYXdzECoaDJNeh6+24Lg/DF4MziKrAQ7XDChYKiME/Lz1FnblMCyDcoZxGYZXzmq41Z04UT1EVqwnVu6A03kEh5uJ5326pJwnTs551jx+z6UdngqK2mYAUODafrdGw7ro7QFPKRpwfQbRh7WLwrU0VyAMAJtzrF75GfHVQPS4rRNjOyAQkY2NwmrncwMFA8XimYoxuhT1Sif9R46xHobnWTE6kulsIT5VA40PpEzPdsYNDInjw/TpL5JSywYq6UfQhijk6O/BBQ==",
  "user": {
    "firstname": "new",
    "lastname": "user",
    "email": "user@new.com",
    "password": "1234",
    "phone": "890765478",
    "usertypereg": "yes",
    "gender": "male"
  },
  "status": "success"
}
```

***Failure***:


```
#!json

{
  "error": "email already exist",
  "status": "error"
}
```

***LIST OF USERS: ***

### GET (/users.json) ###

***Headers*** :

Content-Type = application/json

***Query Params***
     
accesstoken = FQoDYXdzECsaDFRh89GNdJthk6Ni9SKrATbTCgNxUebWXv3JgMlOHAGVKFIQ/SLuIzVyp/fnXvEff+2BLy6UHdJMte/9UbA0/6MSPSH9gQOG1zucoHBuO8ZemwitfNt+fqHSBg9ACTW1QrT84dkSRjF0z4d5FMhoZ2CgQiravmeyn9IKtNf0hxLpdvtDbOjxlvH2mK32ufKWo43dTV9SPeOIsI9MY4rVN5QnFd9IaBGJscck4ejDla2VhcuXe5oqI4CFbCicgvDBBQ==

***Response***:

***Success***:


```
#!json
{
  "users": [
    {
      "firstname": "kvana",
      "lastname": "test12",
      "phone": "9492405166",
      "email": "kvanatest12@gmail.com",
      "gender": "male",
      "usertypereg": "yes"
    },
    {
      "firstname": "niranjan",
      "lastname": "L",
      "phone": "9030904071",
      "email": "niranjan.lagi@gmail.com",
      "gender": "male",
      "usertypereg": "yes"
    },
    {
      "firstname": "niranjan",
      "lastname": "l",
      "phone": "7890123456",
      "email": "niranjan@gmail.com",
      "gender": "male",
      "usertypereg": "no"
    }
   ],
  "status": "Success"
}
```
*** SEARCH USER: ***           

### POST(/messages/search.json) ###

***Headers*** :

Content-Type = application/json

***Body ***:

search = test@test.com

accesstoken = FQoDYXdzEFgaDPePm6rWkJaFXt3LPyKrAfNJ%2BEpd87rh9ESGJqQ%2BMLjNz8BRVN5r0KlQu063u2IL7li13TZfRMnKA0f53cfQNbdpF14IZRRQhh3seIf9YMSpMgajzAeySJeYZJjyjUs8d0%2BC7ehp92Sm9F%2F1X2pK5XnCBa2d4ZTCBw3NufkxiLV2oeZ76Q0%2FeZaV2JS8WKWUAGeJCAmiIXbmZ8rSJL7mV3yaE9T1QtbU6XOUv3s5cfGvz%2BfDYaDX2avvfyi24PnBBQ%3D%3D

***Response***:

***Success***:


```
#!json

{
  "searched user": {
    "firstname": "user",
    "lastname": "name",
    "phone": "9080907080",
    "email": "test@test.com",
    "gender": "male",
    
  },
  "status": "success"
}


```
***Failure***:


```
#!json

{
  "searched user": "Accesstoken Invalid/Expired",
  "status": "failure"
}
```




*** STRIPE PAYMENT: ***           

### POST(/charges.json) ###

***Headers*** :

Content-Type = application/json

***Body ***:

email = kvanatest12@gmail.com
stripeToken = tok_19K3ST2QtPMZ9oMZX8sL6PPF
accesstoken = FQoDYXdzEOz//////////wEaDNWtfPbW0gT1tgpULCKrAZMkjEpg4QZWu26d3hJL51v9zHfCNPowwy4OAPttZOEAuSrt/uwYD2U6x/WjFCIrajyVyMJeQZWebSX5vA911REJaDCfiCKzxQcn2vcAzuVQKEvqehGkfd4rehAa+COvaIcesWJN/mh+xetgIX3yd6JtCi3vb4UbYsZbA+AiPrMulmnIokOFDIV7h14jcXrHICt4mUfNj+hy64SpxgC8a6rMtF54KXTrlm/iHyiu2+XBBQ==

***Response***:

***Success***:
```
#!json
{
  "subscribed_user": ["kvanatest12@gmail.com"],
  "status": "success"
}
```

***Failure***:
```
#!json
{
  "error": "invalid email/stripeToken",
  "status": "error"
}
```



*** CREATE OPINION: ***           

### POST(/messages/create.json) ###

***Headers*** :

Content-Type = application/json

***Body ***:

accesstoken = FQoDYXdzEOz//////////wEaDNWtfPbW0gT1tgpULCKrAZMkjEpg4QZWu26d3hJL51v9zHfCNPowwy4OAPttZOEAuSrt/uwYD2U6x/WjFCIrajyVyMJeQZWebSX5vA911REJaDCfiCKzxQcn2vcAzuVQKEvqehGkfd4rehAa+COvaIcesWJN/mh+xetgIX3yd6JtCi3vb4UbYsZbA+AiPrMulmnIokOFDIV7h14jcXrHICt4mUfNj+hy64SpxgC8a6rMtF54KXTrlm/iHyiu2+XBBQ==
email = kvanatest12@gmail.com
title = "Opinion title"
description = "Opinion Description"

***Response***:

***Success***:
```
#!json
{
  "message": {
    "message_id": "c0035784-f28b-467c-9ff6-b8dc764f9b41",
    "message_title": "ruby gems",
    "message_description": "RubyGems is a package manager for the Ruby programming language that provides a standard format for distributing Ruby programs and libraries (in a self-contained format called a \"gem\"), a tool designed to easily manage the installation of gems, and a server for distributing them. The interface for RubyGems is a command-line tool called gem which can install libraries and manage RubyGems. RubyGems integrates with Ruby run-time loader to help find and load installed gems from standardized library folders.Though it is possible to use a private RubyGems repository, the public repository is most commonly used for gem management. There are about 123,000 gems in the public repository with over 9.8 billion downloads. The public repository helps users find gems, resolve dependencies and install them. RubyGems is bundled with the standard Ruby package as of Ruby 1.9",
    "seekeremail": "lniranjan0522@gmail.com",
    "giveremail": "niranjan.kvana@gmail.com",
    "givername": "Niranjan L",
    "seekername": "niranjan L",
    "timestamp": 1481008107
  },
  "status": "success"
}
```

***Failure***:
```
#!json
{
  "error": "invalid parameters",
  "status": "error"
}
```