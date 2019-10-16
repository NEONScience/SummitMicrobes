# Summit Microbes
This is a working data repository for the 2019 NEON Science Summit Soil Micro/Biogeochemistry Working Group

## Working in this repository

1. To work on this repository fork the repository to your github repo. This acts as a bridge between the original repository and your personal copy. You can submit "pull requests" to offer changes to the original project.
2. Clone your fork. Once you have forked your repository, clone the repository to your desktop
3. Make and push changes. When you're ready to submit your changes, stage and commit your changes and push to your repository.
4. Making a pull request. When you're ready to add your changes to the final project (this repo) go to your forked repository and you will see a banner indicating that you have pushed a new branch and that you can submit this branch "upstream", to the original repository. Type in information and rationale as to why you're making this pull request and then send the pull request to this master repository.


# Introduction to Version Control with Git ##
this link below is a helpful guide
[https://guides.github.com/activities/hello-world/](https://guides.github.com/activities/hello-world/)

## first fork the repository to your github account

```

fork = copy repository on github
clone = copy to local machine
```

## copy to your local machine by moving to the directory you would like to clone to
```

cd ~/Documents #moves to documents from your home directory
mkdir DirectoryName #make a directory to add your github clone to
cd DirectoryName
```


## clone respository with https link from your forked repository
```

git clone https://github.com/<username>/GalleryLab.git #should differ in your forked repository
git config --global user.name "<githubusername>"
git config --global user.email <githubemail>
git init . #initialize current wd
```


# Add --> Commit --> Push Data
add is the staging command for git. *want to use add the most when working with git* <br>
want to add, but not ready to commit <br>
adding means can work on it <br>
commit is where you get to unique id <br>
commit is focal point of version control, where info is being stored forever <br>
with IDs can go back in time to the old versions you have made <br>
push uploads them to github <br>
refer to the guide link at the top of this tutorial on pushing sensitive data, passwds etc. <br>

```
mkdir example_directory
cd example_directory
nano sometextfile.txt
```

write some text and save out
```

git add sometextfile.txt
git status #see everything that has been changed since last commit
git commit -m 'added example text file' # put in some useful comment that has been
 changed since last commit
git push
```

we have now created a text file with command line in a new directory <br>
added the textfile to the staging area <br>
committed the file with a unique I.D. <br>
and pushed to a publicly available server to be reiterated over <br>

# After each push, you can either set up credential caching for HTTPS access or set up SSH keys
[http://happygitwithr.com/credential-caching.html](http://happygitwithr.com/credential-caching.html) #credential-caching <br>
[http://happygitwithr.com/ssh-keys.html](http://happygitwithr.com/ssh-keys.html) #ssh-keys
https keychain is recommended by github

