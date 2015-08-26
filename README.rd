#summary How to install  BigBlueButton 0.8 on Ubuntu 10.04 in under 30 minutes

<wiki:toc max_depth="3" />

= Before you install =

These instructions require you install !BigBlueButton 0.8 on a Ubuntu 10.04 32-bit or 64-bit server (or desktop).  We've not tested the installation on earlier or later versions of Ubuntu.

We recommend installing !BigBlueButton on a dedicated (non-virtual) server for optimal performance.  To install !BigBlueButton, you'll need root access to a Ubuntu 10.04 server with

  # 2 GB of memory (4 GB is better)
  # Dual-core 2.6 GHZ CPU (quad core is better)
  # Ports 80, 1935, 9123 accessible 
  # Port 80 is not used by another application
  # 50G of free disk space (or more) for recordings

In addition to the above, the locale of the server must be en_US.UTF-8.  You can verify this by

{{{
$ cat /etc/default/locale
LANG="en_US.UTF-8"
}}}

To verify that port 80 is not in use by another application, you can type

{{{
   sudo apt-get install lsof
   lsof -i :80
}}}



== Upgrading from an earlier !BigBlueButton 0.8 beta ==

If you are upgrading from an earlier !BigBlueButton 0.8 beta/release candidate, please note, if you've made custom changes to BigBlueButton, such as

 * applied custom branding
 * modified /var/www/bigbluebutton/client/conf/config.xml
 * modified /var/www/bigbluebutton-default/index.html
 * modified API demos
 * modified settings to FreeSWITCH configurations
 * etc ...

then you'll need to backup your changes before doing the following upgrade, after which you can reapply the changes.

To do the following

{{{
   sudo apt-get update
   sudo apt-get dist-upgrade
}}}

At some point in the process you may be asked to update configuration files, as in

{{{
  Configuration file `/etc/nginx/sites-available/bigbluebutton' 
   ==> Modified (by you or by a script) since installation. 
   ==> Package distributor has shipped an updated version. 
     What would you like to do about it ?  Your options are: 
      Y or I  : install the package maintainer's version 
      N or O  : keep your currently-installed version 
        D     : show the differences between the versions 
        Z     : background this process to examine the situation 
   The default action is to keep your current version. 
  *** bigbluebutton (Y/I/N/O/D/Z) [default=N] ? 
}}}

Enter 'Y' each time continue the upgrade.  After !BigBlueButton updates, restart all the processes

After the install finishes, restart your !BigBlueButton server with 

{{{
   sudo bbb-conf --clean 
   sudo bbb-conf --check 
}}}


== Upgrading from !BigBlueButton 0.71a ==

If you are upgrading from !BigBlueButton 0.71a, start [#Upgrading_a_BigBlueButton_0.71a_Server here].

= Installation of !BigBlueButton 0.8 =

== Install Video ==
To make it easy for you to setup your own !BigBlueButton 0.8 server, we've put together the following overview video.

<wiki:video url="http://www.youtube.com/watch?v=A_rYw82-9Bs" width=853 height=500/>

We recommend you following the video with these step-by-step instructions below.

== 1. Update your server == 

You first need to give your server access to the !BigBlueButton package repository for 0.8.

In a terminal window, copy and paste the following commands.

{{{
# Add the BigBlueButton key
wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add -

# Add the BigBlueButton repository URL and ensure the multiverse is enabled
echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse" | sudo tee -a /etc/apt/sources.list

}}}

After you've made the above changes, do a dist-upgrade to ensure your running the latest packages and your server is up-to-date before installing !BigBlueButton.

{{{
sudo apt-get update
sudo apt-get dist-upgrade

}}}

If you've not updated in a while, apt-get may recommend you reboot your server after `dist-upgrade` finishes.  Do the reboot before proceeding to the next step.

== 2. Install Ruby == 
The record and playback infrastructure uses Ruby for the processing of recorded sessions.  

First, you'll need to install the following dependencies to compile ruby.

{{{
sudo apt-get install zlib1g-dev libssl-dev libreadline5-dev libyaml-dev build-essential bison checkinstall libffi5 gcc checkinstall libreadline5 libyaml-0-2

}}}

Next, create a file called `install-ruby.sh` and copy and paste in the following script.

{{{
#!/bin/bash
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xvzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --prefix=/usr\
            --program-suffix=1.9.2\
            --with-ruby-version=1.9.2\
            --disable-install-doc
make
sudo checkinstall -D -y\
                  --fstrans=no\
                  --nodoc\
                  --pkgname='ruby1.9.2'\
                  --pkgversion='1.9.2-p290'\
                  --provides='ruby'\
                  --requires='libc6,libffi5,libgdbm3,libncurses5,libreadline5,openssl,libyaml-0-2,zlib1g'\
                  --maintainer=brendan.ribera@gmail.com
sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.2 500 \
                         --slave /usr/bin/ri ri /usr/bin/ri1.9.2 \
                         --slave /usr/bin/irb irb /usr/bin/irb1.9.2 \
                         --slave /usr/bin/erb erb /usr/bin/erb1.9.2 \
                         --slave /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.2
sudo update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.9.2 500

}}}

Next, run the script

{{{
chmod +x install-ruby.sh
./install-ruby.sh
}}}

After the install finishes, type `ruby -v`.  You should see the ruby interpreter output `1.9.2p290` (or later). 

{{{
$ ruby -v
ruby 1.9.2p290 (2011-07-09 revision 32553)
}}}

Next type `gem -v`.
{{{
$ gem -v
1.3.7
}}}

Finally, to make sure you can install gems, type `sudo gem install hello` (!BigBlueButton does not need the gem hello; rather, we're just testing to makes sure gem is working properly).

{{{
$ sudo gem install hello
Successfully installed hello-0.0.1
1 gem installed
Installing ri documentation for hello-0.0.1...
Installing RDoc documentation for hello-0.0.1...
}}}

Make sure you can execute the above three commands without errors before continuing with these instructions.  If you do encounter errors, please post to [http://groups.google.com/group/bigbluebutton-setup/topics?gvc=2&pli=1 bigbluebutton-setup] and we'll help you resolve the errors.

You might be wondering why not use the default Ruby packages for Ubumtu 10.04?  Unfortunately, they are out of date.  Thanks to [http://threebrothers.org/brendan/blog/ruby-1-9-2-on-ubuntu-11-04/ Brendan Ribera] for the above script for installing the latest ruby on Ubuntu 10.04 as a package.

== 3.  Install !BigBlueButton == 
We're now ready to install !BigblueButton. Type

{{{
   sudo apt-get install bigbluebutton
}}}


This single command is where all the magic happens.  This command installs *all* of !BigBlueButton components with their dependencies.  Here's a screen shot of the packages it will install. 

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/install_ubuntu_08/apt-get-install.png

Type 'y' and press Enter.  The packaging will do all the work for you to install and configure your !BigBlueButton server.

If you are behind a HTTP Proxy, you will get an error from the package bbb-record-core.  You an resolve this by [#Unable_to_install_gems manually installing the gems].

== 4. Install API Demos ==

To interactively test your !BigBlueButton server, you can install a set of API demos.  

{{{
   sudo apt-get install bbb-demo
}}}

You'll need the bbb-demo package installed if you want to join the Demo Meeting from your !BigBlueButton server's welcome page.  This is the same welcome page you see at [http://demo.bigbluebutton.org our demo server].

Later on, if you wish to remove the API demos, you can enter the command

{{{
   sudo apt-get purge bbb-demo
}}}

== 5. Do a Clean Restart == 

To ensure !BigBlueButton has started cleanly, enter the following commands:

{{{
   sudo bbb-conf --clean
   sudo bbb-conf --check
}}}

The output from `sudo bbb-conf --check` will display your current settings and, after the text, "** Potential problems described below **", print any potential configuration or startup problems it has detected.  

Got to [#Trying_out_your_server_(24:42_minutes_later) Trying out your sever].





= Upgrading a !BigBlueButton 0.71a Server =

The following steps will upgrade a standard installation of !BigBlueButton 0.71a to 0.8.

A 'standard installation' is an installation of !BigBlueButton 0.71a that has been configured using the standard commands

{{{
   sudo bbb-conf --setip <ip/hostname>
   sudo bbb-conf --setsalt <salt>
}}}

If you've made custom changes to !BigBlueButton 0.71a, such as  
  * applied custom branding
  * modified `/var/www/bigbluebutton/client/conf/config.xml`
  * modified `/var/www/bigbluebutton-default/index.html`
  * modified API demos
  * etc ...

then you'll need to backup your changes before doing the following upgrade, after which you can reapply the changes.

== 1.  Update your server == 

First, let's update all the current packages on your server (including the kernel) to ensure your starting with an up-to-date system.

{{{
sudo apt-get update
sudo apt-get dist-upgrade
}}}

If you've not updated in a while, apt-get may recommend you reboot your server after `dist-upgrade` finishes.  Do the reboot before proceeding to the next step.

== 2.  Install Ruby == 

Follow the instructions [#2._Install_Ruby here].

== 3.  Remove FreeSWITCH 1.0.6 ==

This step will uninstall FreeSWITCH 1.0.6.  

!BigBlueButton 0.8 requires FreeSWITCH 1.0.7 for recording of sessions.   In later steps, the !BigBlueButton 0.8 will install and configure FreeSWITCH 1.0.7.

Before upgrading, first remove the older FreeSWITCH packages.

{{{
sudo apt-get purge freeswitch freeswitch-sounds-en-us-callie-16000 freeswitch-sounds-en-us-callie-8000 freeswitch-sounds-music-16000
}}}

Check to ensure that there are no remaining FreeSWITCH packages.

{{{
   dpkg -l | grep freesw
}}}

If there are any remaining packages, such as freeswitch-lang-en, then purge those as well

{{{
   sudo apt-get purge freeswitch-lang-en
}}}


== 4.  Upgrade !BigBlueButton == 

First, update the !BigBlueButton repository URL to the beta repository.

{{{
echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
}}}

Next, update the local  packages.  This will make `apt-get` aware of the newer packages for !BigBlueButton 0.8.

{{{
sudo apt-get update
}}}

The following command will upgrade your packages to the latest beta.

{{{
sudo apt-get dist-upgrade
}}}

After a few moments you'll be prompted whether you want to overwrite `/etc/nginx/sites-available/bigbluebutton`.

{{{
Configuration file `/etc/nginx/sites-available/bigbluebutton'
 ==> Modified (by you or by a script) since installation.
 ==> Package distributor has shipped an updated version.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : background this process to examine the situation
 The default action is to keep your current version.
*** bigbluebutton (Y/I/N/O/D/Z) [default=N] ?
}}}

Type 'y' and hit Enter.  
 

== 5. Install FreeSWITCH Configuration and API demos ==
Now let's install and configure FreeSWITCH 1.0.7.

{{{
sudo apt-get install bbb-freeswitch-config
}}}

Install the API demos to interactively try !BigBlueButton.

{{{
sudo apt-get install bbb-demo
}}}

== 6. Remove unneeded packages ==
We no longer need activmq, so let's remove it.  The command `sudo apt-get autoremove` will remove all remaining packages that have no reference.

{{{
sudo apt-get purge activemq
sudo apt-get autoremove
}}}

== 7. Do a clean restart ==

Let's do the standard clean restart and then check the system for any potential problems.

{{{
sudo bbb-conf --clean
sudo bbb-conf --check
}}}


= Trying out your server (24:42 minutes later) =

You've got a full !BigBlueButton server up and running (don't you just love the power of Ubuntu/Debian packages). Open a web browser to the URL of your server.  You should see the !BigBlueButton welcome screen.

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/install_ubuntu_08/welcome.png

To start using your !BigBlueButton server, enter your name and click the 'Join' button.  You'll join the Demo Meeting.

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/install_ubuntu_08/running.png

If this is your first time using !BigBlueButton, take a moment and watch these [http://bigbluebutton.org/content/videos overview videos].

To record a session, click 'API Demos' on the welcome page and choose 'Record'.  Start a meeting and upload slides.  When you are done, click 'Logout' and return to the 'API Demos' and the record demo.  Wait a few moments and refresh your browser, you should see your recording appear.

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/install_ubuntu_08/record.png

Click 'Slides' to playback the slides, audio, and chat of the recording.

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/install_ubuntu_08/playback.png

The following [http://www.youtube.com/watch?v=4b_tC1JEX1E YouTube Video] will walk you through using record and playback.

== URL and salt for 3rd party integrations ==
If you want to use !BigBlueButton with a [http://www.bigbluebutton.org/open-source-integrations/ 3rd party integration], you can get the URL and security salt from your server using the command `bbb-conf --salt`.

{{{
$ bbb-conf --salt

       URL: http://192.168.0.36/bigbluebutton/
      Salt: b22e37979cf3587dd616fa0a4e6228
}}}

We hope you enjoy using !BigBlueButton and welcome your feedback!

= Troubleshooting =

If you don't find an answer to your questions below, check out our [http://code.google.com/p/bigbluebutton/wiki/FAQ Frequently Asked Questions.]  A common question is  [http://code.google.com/p/bigbluebutton/wiki/FAQ#Can_I_run_multiple_virtual_classrooms_in_a_single_BigBlueButton How do I setup multiple virtual classrooms?]


== Run sudo bbb-conf --check ==
We've built in a !BigBlueButton configuration utility, called `bbb-conf`, to help you configure your !BigBlueButton server and trouble shoot your setup if something doesn't work right.

If you think something isn't working correctly, the first step is enter the following command.

{{{
   sudo bbb-conf --check
}}}

This will check your setup to ensure the correct processes are running, the !BigBlueButton components have correctly started, and look for common configuration problems that might prevent !BigBlueButton from working properly.  For example, here's the output on one of our internal servers:

http://bigbluebutton.googlecode.com/svn/trunk/bbb-images/vm/71check.png


If you see text after the line `** Potential problems described below **`, then `bbb-conf` detected something wrong with your setup.

== Dependencies are not met ==

For some VPS installations of Ubuntu 10.04, the hosting provider does not give a full `/etc/apt/source.list`.  If you are finding your are unable to install a package, try replacing your `/etc/apt/sources.list` with the following


{{{
#
#
# deb cdrom:[Ubuntu-Server 10.04 LTS _Lucid Lynx_ - Release amd64 (20100427)]/ lucid main restricted

# deb cdrom:[Ubuntu-Server 10.04 LTS _Lucid Lynx_ - Release amd64 (20100427)]/ lucid main restricted
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

deb http://us.archive.ubuntu.com/ubuntu/ lucid main restricted
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://us.archive.ubuntu.com/ubuntu/ lucid-updates main restricted
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://us.archive.ubuntu.com/ubuntu/ lucid universe
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid universe
deb http://us.archive.ubuntu.com/ubuntu/ lucid-updates universe
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid multiverse
deb http://us.archive.ubuntu.com/ubuntu/ lucid-updates multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ lucid-updates multiverse

## Uncomment the following two lines to add software from the 'backports'
## repository.
## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
# deb http://us.archive.ubuntu.com/ubuntu/ lucid-backports main restricted universe multiverse
# deb-src http://us.archive.ubuntu.com/ubuntu/ lucid-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu lucid partner
# deb-src http://archive.canonical.com/ubuntu lucid partner

deb http://security.ubuntu.com/ubuntu lucid-security main restricted
deb-src http://security.ubuntu.com/ubuntu lucid-security main restricted
deb http://security.ubuntu.com/ubuntu lucid-security universe
deb-src http://security.ubuntu.com/ubuntu lucid-security universe
deb http://security.ubuntu.com/ubuntu lucid-security multiverse
deb-src http://security.ubuntu.com/ubuntu lucid-security multiverse
}}}

then do

{{{ 
   sudo apt-get update
}}}

and try installing !BigBlueButton again.


== Change the !BigBlueButton Server's IP ==

A common problem is the default install scripts in for !BigBlueButton configure it to list for an IP address, but if you are accessing your server via a DNS hostname, you'll see the 'Welcome to Nginx' message.

To change all of !BigBlueButton's configuration files to use a different IP address or hostname, enter

{{{
   sudo bbb-conf --setip <ip_address_or_hostname>
}}}

For more information see [BBBConf bbb-conf options]. 

== Address already in use ==

If you have apache2 already running on the server, you'll likely see the following error messages from nginx when it starts.

{{{
Restarting nginx: [emerg]: bind() to 0.0.0.0:80 failed (98: Address
already in use)
}}}

If you see these errors, it means that nginx is unable to bind to port 80 on the local server.  To find out what's binding to port 80, do the following

{{{
   sudo apt-get install lsof
   lsof -i :80
}}}

If you see apache2 listed, then stop apache2 and start nginx

{{{
   sudo /etc/init.d/apache2 stop
   sudo /etc/init.d/nginx start
}}}

== Unable to install gems ==
The install script for bbb-record-core needs to install a number of ruby gems.  However, if you are behind a HTTP_PROXY, then the install script for bbb-record-core will likely exit with an error.  This occurs because the bash environment for bbb-record-core will not have a value for HTTP_PROXY.

You can resolve this by manually installing the gems using the following script.
{{{
#!/bin/bash

export HTTP_PROXY="<your_http_proxy>"

gem install --http-proxy $HTTP_PROXY builder -v 2.1.2
gem install --http-proxy $HTTP_PROXY diff-lcs -v 1.1.2
gem install --http-proxy $HTTP_PROXY json -v 1.4.6
gem install --http-proxy $HTTP_PROXY term-ansicolor -v 1.0.5
gem install --http-proxy $HTTP_PROXY gherkin -v 2.2.9
gem install --http-proxy $HTTP_PROXY cucumber -v 0.9.2
gem install --http-proxy $HTTP_PROXY cucumb -v 0.9.2
gem install --http-proxy $HTTP_PROXY curb -v 0.7.15
gem install --http-proxy $HTTP_PROXY mime-types -v 1.16
gem install --http-proxy $HTTP_PROXY nokogiri -v 1.4.4
gem install --http-proxy $HTTP_PROXY rack -v 1.2.2
gem install --http-proxy $HTTP_PROXY redis -v 2.1.1
gem install --http-proxy $HTTP_PROXY redis-namespace -v 0.10.0
gem install --http-proxy $HTTP_PROXY tilt -v 1.2.2
gem install --http-proxy $HTTP_PROXY sinatra -v 1.2.1
gem install --http-proxy $HTTP_PROXY vegas -v 0.1.8
gem install --http-proxy $HTTP_PROXY resque -v 1.15.0
gem install --http-proxy $HTTP_PROXY rspec-core -v 2.0.0
gem install --http-proxy $HTTP_PROXY rspec-expectations -v 2.0.0
gem install --http-proxy $HTTP_PROXY rspec-mocks -v 2.0.0
gem install --http-proxy $HTTP_PROXY rspec -v 2.0.0
gem install --http-proxy $HTTP_PROXY rubyzip -v 0.9.4
gem install --http-proxy $HTTP_PROXY streamio-ffmpeg -v 0.7.8
gem install --http-proxy $HTTP_PROXY trollop -v 1.16.2
}}}

Once all the gems are installed, you can restart the installation process with the command

{{{
sudo apt-get install -f
}}}
