PSEnvironment
=============

A set of functions to make dealing with Environment Variables easier.

While most local stuff is most easily dealt with using $env, once you need to edit machine and user level environment variables powershell becomes a lot less helpful. This module attempts to resolve that.

It also has specific functions for dealing with the PATH environment variable.

**Repair-EnvironmentPath** - Fix common PATH issues, e.g. missing paths, duplicates, empty entries etc.

**Add-EnvironmentPath** - Add a path to the PATH.

**Remove-EnvironmentPath** - Remove a path from the PATH.

All functions take a ```-Scope``` parameter (default 'process') to target where the value should be set.

Function that can change the system support ```-WhatIf```

Installation
------------

Clone into your powershell modules folder and Import-Module PSEnvironment

License
-------

The MIT License (MIT)

Copyright (c) 2015 Martin Gill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

