require 'digest'
require_relative "./Revlog.rb"


#$path = "D:/CSC 453/Rev Project/test.txt" 
#$repo = repository.new(path, 1)
$rev = 3 # rev is a local revision ID

class TestRevlog
    @r_obj
    @partialResult

    def testRevlog_init
        indexfile = "D:/Workbin Rochester/CSC 453/csc_453_revlog_project/dummyIndexFile.txt"
        datafile = "D:/Workbin Rochester/CSC 453/csc_453_revlog_project/dummyDataFile.txt"
        r_obj = Revlog.new(indexfile, datafile)
        
        #p r_obj.nodemap()
        if (r_obj.nodemap() =={:dummyLocalID=>:nullid,:nullid=>:dummyLocalID,"930ec9f4b52b7ca555436720d5375c4d"=>0})&&(r_obj.index==[[3,10,0,0,0,"930ec9f4b52b7ca555436720d5375c4d"]])
            p "Passed: #{__method__} " 
        else
           # raise "Error: #{__method__} " 
           p "Error: #{__method__} " 
        end
        @r_obj=r_obj
    end


    def testRevlog_tip  
        if @r_obj.tip()== 0
            p "Passed: #{__method__} " 
        else
            raise "Error: #{__method__} " 
        end
    end


    def testRevlog_rev
        if @r_obj.rev("930ec9f4b52b7ca555436720d5375c4d")== 0
            p "Passed: #{__method__} " 
        else
            raise "Error: #{__method__} " 
        end
    end


    def testRevlog_parents
        prts = @r_obj.parents(0)
        #p prts
        if prts[0] == 0 && prts[1] == 0
            p "Passed: #{__method__} " 
        else
            raise "Error: #{__method__} " 
        end
    end

    def testRevlog_start
        if @r_obj.start(0)== 3
            p "Passed: #{__method__} " 
        else
            raise "Error: #{__method__} " 
        end
    end

    def testRevlog_revision
        @partialResult = @r_obj.revision(0)
        p @partialResult
        p "revision test ends"
    end

    def testRevlog_addrevision
        #p @r_obj.addrevision(@partialResult+"dummyAddReversionTest",0)
        p @r_obj
        @r_obj.addrevision("dummyAddReversionTest")
    end

=begin
    def testRevlog_open
        fn = @r_obj.open("D:/CSC 453/Rev Project/test.txt/dummyIndexFile.i")

        raise "Error: #{__method__} " if (fn == "D:/CSC 453/Rev Project/test.txt/dummyIndexFile.i") ==false
        p "Passed: #{__method__} "
    end 
=end 

end
testObj = TestRevlog.new
testObj.testRevlog_init
#testObj.testRevlog_tip  
#testObj.testRevlog_rev
#testObj.testRevlog_parents
#testObj.testRevlog_start
#testObj.testRevlog_revision
testObj.testRevlog_addrevision
testObj.testRevlog_revision