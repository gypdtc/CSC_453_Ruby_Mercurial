# CSC_453_Ruby_Mercurial
This is a project from CSC 453 class by professor Chen Ding in U of R

We tried managed to implement the functions from mercurial v0.1 in Ruby.
This simple project can support the create, add, delete, commit, merge, checkout .. functions as mercurial.

To experience this project, you should first clone it to a directory. Then under the root directory,
open your shell and type your command just like mercurial.
Ruby is required.

There are five people in this group.

1.Yupeng Gou
2.Guangda luo
3.Lisi Luo
4.Ruguo Lin
5.Ning Gu


My role is the quality asurance and project lead, I was in charge of group coordination and integration testing between modules. I also contributes to the repository.rb file.

Yupeng Gou
University of Rochester

The following is some instructions on how to use the commands.

1. create
expected number of arguments: 0
e.g: ruby UI create

2. add
expected number of arguments: multiple (filenames)
e.g: ruby UI add t1.txt/ ruby UI add t1.txt t2.txt t3.txt

3. delete
expected number of arguments: multiple (filenames)
e.g: ruby UI delete t1.txt/ ruby UI delete t1.txt t3.txt

4. commit
expected number of arguments: 0
e.g: ruby UI commit

5. checkout
expected number of arguments: 1 (a revision number)
e.g: ruby UI checkout 0

6. stat
expected number of arguments: 0
e.g: ruby UI stat
#display status of files in current directory, C => file changed.

7. index
expected number of arguments: 1 (a filename)
e.g: ruby UI index t1.txt

8. history
expected number of arguments: 0
e.g: 
ruby UI add t1.txt
ruby UI commit
ruby UI history # A commit history (changed files) would be displayed
ruby UI add t2.txt
ruby UI commit
ruby UI history # Two commit histories (changed files) would be displayed

9. help
expected number of arguments: 0
e.g: ruby UI help #displaying the list of implemented commands

10.(extra) merge
expected number of arguments: 1 arg:(absolute path of another repository)
e.g: ruby UI merge C:\master\new. 

11.(extra) compress
We have add the compress_encode and decompress_decode function inside compress.rb file to compress and encode the "00manifest.i" and "00changelog.i" file, and file inside index folder.

12.The acceptance tests
We find it is different to run a command in shell directly or by ruby file , so please delete the code
from line 167 to line 189 in repository.rb , Then execute the Acceptan_test.rb , it will test the
create , add ,delete ,commit , functions of the project. And this change would affect the checkout function,
So checkout can not work correctly with those code.

13. An example sequence of executions =>(and expected results)

(In repository A)
ruby UI create 
ruby UI add t1.txt
ruby UI commit => file 't1.txt' added to repo A, changelog/manifest/datafile/indexfile modified
ruby UI stat => 't1.txt' would be marked as'C'
ruby UI history => one commit record would be displayed, showing modified time/modified filenames etc.
ruby UI add t2.txt
ruby UI commit => file 't2.txt' added to repo A, changelog/manifest/datafile/indexfile modified
ruby UI stat => 't2.txt' would be marked as 'C'
ruby UI history => two commit records would be displayed (since commit has been executed twice), showing modified time/modified filenames etc.
ruby UI delete t2.txt
ruby UI commit => file 't2.txt' deleted from repo A, changelog/manifest/datafile/indexfile modified
ruby UI checkout 2 => repo A recovered to revision numbered 2, changelog/manifest/datafile/indexfile modified
ruby UI checkout 1 => repo A recovered to revison numbered 1, changelog/manifest/datafile/indexfile modified

(In repository B)
ruby UI create 
ruby UI add t3.txt
ruby UI commit => file 't3.txt' added to repo B, changelog/manifest/datafile/indexfile modified

(In repository A)
ruby UI merge {the absolute path of repo B} => file 't3.txt' added to repo A, changelog/manifest/datafile/indexfile of repo A modified

