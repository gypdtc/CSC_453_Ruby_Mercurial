require 'digest'
require 'zlib'
load "compress.rb"

md5 = Digest::MD5.new
#md5.update path
s = md5.hexdigest
$nullid = s
$dummyLocalID = -1

module Mdiff
    def patch(oldT, newT)
        temp = ""
        temp << oldT
        return temp if newT == nil
        # p "newT: " , newT
        # p "temp: " , temp
        return temp << newT
    end

    def textdiff(oldT,newT)
        # p "oldT",oldT
        # p "newT",newT
        if oldT[0..-1] == newT[0...oldT.length]
            nnnn = newT[oldT.length..newT.length]
            # p "nnnn",nnnn
            return newT[oldT.length..newT.length]
        else
            len = (newT.split(".txt")[0]+".txt").length
            newnewT = newT[len..newT.length]
            return newnewT
        end

        
    end

    def linesplit(a)
        # p "a: !!",a
        # a.delete!("\n")
        # p "a:!!!!!!!",a
        l = Array.new
        last = 0
        # p "a.index ", a.index("\n")
        # if a.index("\n") == nil
        #     n = 1
        # else
        #     n = a.index("\n") + 1
        # end
        # p "n: ",n
        # while n > 0 do
        #     l << a[last...n]
        #     p "hehe llllllllllllllllllll",l
        #     last = n
        #     if a.index("\n", n)==nil
        #         n = 0 
        #     elsif
        #         n = a.index("\n", n) + 1
        #     end
        #     # p "l = !!!  ",l
        # end
        l << a[last..-1] if last < a.length
        # p "hehe llllllllllllllllllll 222",l
        # p "linesplit: res l= ",l
        return l
    end
end


class Revlog
    include Mdiff
    attr_accessor :indexfile
    attr_accessor :datafile
    attr_accessor :index
    attr_accessor :nodemap
    def initialize(indexfile,datafile)
        # p "runing revlog.init!!!!!!!!!!!!!!!!!!!!"
        # print indexfile
        @indexfile = indexfile # a string showing the absolute name
        @datafile = datafile
        # p @indexfile, @datafile
        @index = Array.new(){|element| element} # use lambda function to make the stored object mutable
        @nodemap = Hash[$dummyLocalID =>$nullid, $nullid => $dummyLocalID ]
        # p '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
        # p "index file",@indexfile
        begin
            n=0
            # p "@indexfile path !!!"
            # p @indexfile
            # p "open file !!!!!!!!"
            f = self.open(@indexfile) 
            # p "fffffffffff",f
            raise "file cannot be opened? " if f == nil
            # p "opened file !!!!!!!!"
            # p "file ffffffffffffffffffffffffff",f
            fread = f.readlines()

            # p "fread #{fread}"
            # read the file line by line

            fread.each do |fline|
                    # p "revlog_DE", fline
                    fline2 = decompress_decode(fline) # decompress and decode
                    # p 'fline2 fline2 fline2 fline2'
                    # p fline2
                    #p "in loop now"
                    e = fline2.split(" ")#.map{|s|s.to_sym}
                    # p "eeeeeeeeeee", e
                    e = e[0..5]
                    if not e.empty?
                    #tempE = e
                        for i in 0..4
                            e[i]=e[i].to_i
                        end
                    # p "in loop"
                        # p "@nodemap source",e,e.count,n #e5 = node_id
                        # p "nodeid e5", e[5]
                        @nodemap[e[5]] = n
                        # p "nodemap after generation", @nodemap
                        @index << e
                        n = n+1
                    end
                
                    # p "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            end
            f.close

        rescue 
            # p "revlog init error!!!!!!!!!!!!!!!!!!"
        end
       # p @index
       # p @nodemap
       # p "initialization finished"
    end

    def index()
        return @index
    end

    def nodemap()
        return @nodemap
    end
    def open(fn, mode='r')
        #if mode == 'a'
        #        File.open(fn,mode) { |f| f.write('here is some text') }
        #end
        return File.open(fn,mode)# same as File.new if no block is given

    end

    def tip()
        # p '!!!!!!!!!!!!!!!!!!!!!!!'
        # p @index.length
        # p @index
        return @index.length - 1
    end

    def node(rev)
        # p ']]]]]]]]]]]]]]'
        # p @index
        # p rev
        if rev < 0 
            # p "null null null null null null null null null null null ", $nullid
            return $nullid
        else
            # p "@index!!!!!!!!!!@index",@index
            return @index[rev][5]
        end
    end

    def rev(node)
        # p "nodemap  ",@nodemap
        return @nodemap[node]
    end

    def parents(rev)
        return @index[rev][3..4]
    end

    def start(rev)
        return @index[rev][0]
    end  

    def length(rev)
        return @index[rev][1]
    end

    def end(rev)
        return self.start(rev) + self.length(rev)
    end

    def base(rev)
        # p "index 1111",@index[1]
        # p 'rev',rev
        return @index[rev][2]
    end

    def revision(rev)
        # p "revrev!!",rev
        if rev == -1
            return ""
        end
        # p '---------------'
        # p rev
        # rev = rev - 1
        base = self.base(rev)
        # print "base "
        # p base
        start = self.start(base)
        endPoint = self.end(rev)

        f = self.open(@datafile)
        # p "start!!!!!!!!!!! and End!!!!!!!!!!"
        # p start
        # p endPoint
        f.seek(start)
        data = f.read(endPoint - start)
        # data = f.read()
        # p "data:::::::::::::::::::"
        # p endPoint
        # p start
        # p data
        # p "!!!!!!!!!!!!!!!!!"
        last = self.length(base)
        # p "data data !!!!!!",data
        # p "textTemp: ",data[0...last-1]
        textTemp = data[0...last-1]
        text = textTemp
        #text = Zlib::Inflate.inflate(textTemp)

        (base+1..rev).each do |r|
            s = self.length(r)
            textTemp = data[last...last+s-1]
            #b = Zlib::Inflate.inflate(textTemp)
            b = textTemp
            # p "patch patch patch patch patch patch patch patch patch patch patch text and b ",text,b
            text = patch(text,b)
            # p "after patch text ", text
            last = last + s
        end

        p = self.parents(rev)
        # p "rev and parents",rev,p
        p1 = p[0]
        p2 = p[1]
        n1 = ""    
        n2 = ""
        if p1 != 0 
            n1 = self.node(p1)
        end
        if p2 != 0
            # p "p2p2p2p2p2",p2
            n2 = self.node(p2)
        end
        
        
       # node = Digest::SHA256.digest(n1+n2+text)
        # md5 = Digest::MD5.new
        # p n1
         # p "hahahahahah",text
        #   p n2
        temp = n1 + n2 + text
        # md5.update temp
        # node = md5.hexdigest
        node = temp
        # p node
        # p "change your node"
        # p rev
        # p self.node(rev),node
        if self.node(rev) !=node
            # raise "Consistency check failed #{__method__}"
        end
        # p "RRRRRRRRRRRRRRRRRRRRRRRRR",text
        return text
    end

    def revision2(rev)
        if rev == -1
            return ""
        end
        base = self.base(rev)
        start = self.start(base)
        endPoint = self.end(rev)

        f = self.open(@datafile)
        f.seek(start)
        if f.read(1) == '\n'
            f.seek(start+1)
        end
        data = f.read(endPoint - start)
        last = self.length(base)
        # p "data data !!!!!!",data
        # p "textTemp: ",data[0...last-1]
        textTemp = data[0...last-1]
        text = textTemp
        #text = Zlib::Inflate.inflate(textTemp)

        (base+1..rev).each do |r|
            s = self.length(r)
            textTemp = data[last...last+s-1]
            #b = Zlib::Inflate.inflate(textTemp)
            b = textTemp
            # p "patch patch patch patch patch patch patch patch patch patch patch text and b ",text,b
            text = patch(text,b)
            # p "after patch text ", text
            last = last + s
        end

        p = self.parents(rev)
        p1 = p[0]
        p2 = p[1]
        n1 = ""    
        n2 = ""
        if p1 != 0 
            n1 = self.node(p1)
        end
        if p2 != 0
            n2 = self.node(p2)
        end
        temp = n1 + n2 + text
        node = temp
        if self.node(rev) !=node
            # raise "Consistency check failed #{__method__}"
        end
        # p "text22222222",text
        return text
    end

    def addrevision(text, p1=nil, p2=nil)
        # p '!!!!!!!!!!!!!!!!!!!!!!!!!==============================='
        # p "original text:",text
        if text==nil
            text=""
        end

        # if text == ""
        #     return self.tip()
        # end

        if p1==nil
            p1=self.tip()
        end

        if p2==nil
            p2 = -1
        end

        t = self.tip()
        n = t + 1

        if n>0
            start = self.start(self.base(t))
            endPoint = self.end(t)
            prev = self.revision(t)
            # p "prevprev texttext"
            # p prev
            # p text
            # p "tttttttttext",text
            med = textdiff(prev,text)
            # data = Zlib::Deflate.deflate(med)
            data = med 
            # p "data after textdiff 4e:",data
        end
        # p "data and length",data
        data = "" if data == nil
        if n<=0 or (endPoint+data.length-start) > (2*text.length)
            # data = Zlib::Deflate.deflate(text)
            data = text
            # p "data after assign",data
            base = n
        else
            base = self.base(t)
        end

        offset = 0
        if t>= 0
            offset = self.end(t)
        end

        n1=self.node(p1)
        n2=self.node(p2)
        # md5 = Digest::MD5.new
        # p "NNNNNNNNNNNNNNNNNNNNNNNNNNNN222222222"
        # p n1,n2,text
        n1 = "" if n1 == nil
        n2 = "" if n2 == nil
        text = "" if text == nil
        temp =n1+n2+text
        # md5.update temp
        # node = md5.hexdigest
        # p temp
        node = temp
        # p '====================='
        # p node.is_a?(Stri)
       # node = Digest::SHA256.digest(n1+n2+text)
        # p "nodenodenodenodenodenodenodenodenodenodenodenodenodenode"
        # p node
        e = [offset,data.length,base,p1,p2,node]
        # p offset
        # p data.length
        # p base
        # p p1
        # p p2
        # p node
        # offset
        @index << e
        # p 'indexindexindexindexindexindexindexindexindex'
        # p @index
        # p n
        self.nodemap[node]=n
        entry = ""
        e.each do |c|
            entry << c.to_s
            entry << " "
        end
        # p '!!!!!!>>>>>>>>>>>>>>>'
        # p@indexfile
        # p entry
        # p@datafile
        # p data

        entry = compress_encode(entry) #compress and encode
        # p "addrevision:compress", entry
        self.open(@indexfile,'a').write(entry)
        self.open(@datafile,'a').write(data)
        # p "data",data
        return n
    end





    # a is old_tip,   b is new_tip
    def ancestor(a,b)
        #  [old_tip],[new_tip],{old:1},{new:1}
        def expand(e1,e2,a1,a2)
            ne = Array.new(){|element| element} 
            e1.each do |r|
                p = self.parents(r)
                p1 = p[0]
                p2 = p[1]
                return p1 if a2.has_key?(p1)
                return p2 if a2.has_key?(p2)
                if !a1.has_key?(p1)
                    a1[p1]=1
                    ne << p1
                    if p2 >= 0 && !a1.has_key?(p2)
                        a1[p2]=1
                        ne << p2
                    end
                end
            end
            return expand(e2,ne,a2,a1)
        end
        #           [old_tip],[new_tip],{old:1},{new:1}
        return expand([a],[b],{a => 1},{b => 1})
    end

    #contains all the revision's text into a textList
    # def revisions(list)
    #     # only used by mergedag
    #     textList = Array.new(){|element| element}
    #     list.each do |r|
    #         textList << self.revision(r)
    #    
    #     end
    #     return textList
    # end

    def revisions(list)
        # only used by mergedag
        text = []
        list.each do |r|
            text << self.revision(r)
        end
        # p "revisionsssss text",text
        # p "class of text",text.class()
        # p "class of text.each",text.each
        return text.each
    end


    def mergedag(other, accumulate=nil)
        amap = @nodemap
        # p "amap",amap
        # p "self",self
        bmap = other.nodemap
        i = self.tip()
        # p "old tip",i
        old = i
        #store: [tip, rev(p1), rev(p2)]
        lst = Array.new(){|element| element} 
        #store: 0..old_tip
        rList = Array.new(){|element| element} 

        (0..other.tip()).each do |r|
            id = other.node(r)
            if !amap.has_key?(id)
                i = i+1
                parents_xy = other.parents(r)
                x = parents_xy[0]
                # p "x",x
                y = parents_xy[1]
                xn = other.node(x)
                yn = other.node(y)
                # p "xn",xn
                lst << [r, amap[xn], amap[yn]]
                rList << r
                # node id => new tip
                amap[id]=i
            end
        end

        # 0..old_tip revisions:
        # p "listlistlistlistlist",rList
        r = other.revisions(rList)
        # p "class of r",r.class()
        # p "rrrrrrrrrrr",r
        # p "rst !!",lst
        # r contains all the revision text from 0 to old_tip
        # lst stores: [tip, rev(p1), rev(p2)]
        lst.each do |e|
            totalText = r.next()
            # p "totalText",totalText
            accumulate.call(totalText) if accumulate
            self.addrevision(totalText, e[1], e[2])
        end

        return [old, self.tip()] # old_tip, new_tip

    end


    def resolvedag(oldNode,newNode)
        if oldNode==newNode
            # p "resolvedag 111"
            return nil 
        end
        a = self.ancestor(oldNode,newNode)
        # p "oldNode", oldNode
        # p "newNode", newNode
        # p "ancestor",a
        # if old_tip is the ancestor of new_tip: Use new_tip only
        if oldNode == a 
            # p "resolvedag 222"
            return newNode 
        end
        # if old_tip has nothing to do with new_tip: do merge3()
        # p "resolvedag 333"
        return self.merge3(oldNode,newNode,a)
    end


    def merge(other)
        tempArray = self.mergedag(other)
        #                        old_tip  ,   new_tip
        return self.resolvedag(tempArray[0], tempArray[1])
    end

    # old_tip has nothing to do with new_tip
    def merge3(my, other, base)
        # def temp(prefix, rev)
        #     (fd, name) = tempfile.mkstemp(prefix)
        #     f = os.fdopen(fd, "w")
        #     f.write(self.revision(my))
        #     os.close(fd)
        #     return name
        # end
        # a = temp("local", my)
        # b = temp("remote", other)
        # c = temp("parent", base)
        # # call out to merge here, return success flag
        # cmd = os.environ["HGMERGE"]
        # r = os.system("%s %s %s %s" % (cmd, a, b, c))
        # if r: raise "Merge failed, implement rollback!"
        # t = open(a).read()
        t = self.revision(my)
        return self.addrevision(t, my, other)
    end


end





class Filelog < Revlog # store name and id
    def initialize(repo, path)
        # p "runing filelog init"
        # p path
        @repo = repo
        md5 = Digest::MD5.new
        md5.update path
        s = md5.hexdigest
        # super
        super(File.join("index/",s), File.join("data/",s))
        # super(File.join("",s), File.join("data/",s))
    end

    # this method is not called in the entire file

    def open(file, mode = "r")
        return @repo.open(file, mode)
    end
end



class Manifest < Revlog # contains file name and node id
    include Mdiff
    def initialize(repo)
        @repo = repo
        # p "Manifest @repo: " , repo
        # super
        super("00manifest.i", "00manifest.d")           
    end

    def open(file, mode="r") 
        return @repo.open(file, mode)
    end

    def manifest(rev)
        # p '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!00', rev
        text = self.revision(rev)
        # text = "3123sda\n"
        # p text.is_a?(String)
        # p "manifest text =  " , text
        
        map = {}
        if linesplit(text) != [""]
            for l in linesplit(text) do
                # if (l[-1]=='\n' or l[-1]=='\r') and (l[-2]=='\n')
                #     map[l[32...-3]] = l[0..31] 
                # elsif (l[-1]=='\n' or l[-1]=='\r') and (l[-2]!='\n')
                #     map[l[32...-1]] = l[0..31]
                # else
                ii = l.index("@")
                map[l[(ii+1)..-1]] = l[0...ii]
                # end
                # map[l[41..-1]] = l[0..40]
                # p "mmaappmmaapp",l[41...-3],l[0..40]
            end
        end
        # p "linesplit:::",linesplit(text)
        # p "manifest map: !!!!!!!!!  ",map
        return map
    end

    def addmanifest(map, p1=nil, p2=nil)
        # p "map map map map map map map map map map map map "
        # p map
        map.delete(nil) if map[nil] != nil
        # p "after map map after!!!",map
        files = map.keys
        # p "filesfilesfilesfilesfilesfilesfilesfilesfiles"
        # p files
        files.sort
        # 
        text = ""
        lll = Array.new
        for f in files do
            # p "map f map f map f map f map f map f map f map f map f map f ",map[f]
            # p "fffffffffffffffffffffffffffffffffffffffffffffffffffffff ",f
            # text = text + (map[f] + " " + f + "\n")
            # p "before text",text
            text = text + (map[f] + "@" + f + "\n")
            # p "after text",text
            # text = text + (map[f] + " " + f )
        end
        # text.delete!("\n")
        # p "addmanifest: text !!!!!!!!!!!!!!!!!!!", text
        # d41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427e123123\n\n\n123\n123\n12\n3\n123\n\ndsa\nd\nasd\n\n\n test.txt\n
        return self.addrevision(text, p1, p2)
    end
end

class Changelog < Revlog
    include Mdiff
    include Enumerable
    def initialize(repo)
        @repo = repo

        # p "Changelog @repo: ", @repo
        super("00changelog.i", "00changelog.d")
    end

    def open(file, mode="r")
        return @repo.open(file, mode)
    end

    def extract(text)
        # p "text text ",text
        # l = text.split("\r\n")
        l = text.split(" ")
        # p "llllllllllllllllllll",l
        l.delete("")
        manifest = l[0] # all content of the first line of text
        # p "extract:manifest = ", manifest
        # p "extract l = ",l
        user = l[1] # all content of the second line of text
        date = l[2] # all content of the third line of text
        # last = l.index("\n") # find the index of first '\n'  
        files = Array.new
        # p "last = ",last
        # p "lllll!!!!!!!!",l

        # for f in l[3...-1] do # put the forth line to the last line into files 
        #     files << f[0...-1]
        # end
        files << l[3]
        # files = l[3]
        desc = ""
        # last2 = last + 1
        # p "last2222",last2 
        desc = l[-1] #desc is the last element of the text
        # l2.each{|x| desc += x.to_s } # put the content after \n into a string   
        res = Array.new
        res << manifest
        res << user
        res << date
        res << files
        res << desc
        return res
    end

    def extract2(text)
        # p "text text ",text
        # l = text.split("\r\n")
        l = text.split(" ")
        # p "llllllllllllllllllll",l
        l.delete("")
        manifest = l[-5] # all content of the first line of text
        # p "extract:manifest = ", manifest
        # p "extract l = ",l
        user = l[-4] # all content of the second line of text
        date = l[-3] # all content of the third line of text
        # last = l.index("\n") # find the index of first '\n'  
        files = Array.new
        # p "last = ",last
        # p "lllll!!!!!!!!",l

        # for f in l[3...-1] do # put the forth line to the last line into files 
        #     files << f[0...-1]
        # end
        files << l[-2]
        # files = l[3]
        desc = ""
        # last2 = last + 1
        # p "last2222",last2 
        desc = l[-1] #desc is the last element of the text
        # l2.each{|x| desc += x.to_s } # put the content after \n into a string   
        res = Array.new
        res << manifest
        res << user
        res << date
        res << files
        res << desc
        return res
    end

    def changeset(rev)
        # p "changeset: call extract: ", self.extract(self.revision(rev))
        return self.extract(self.revision(rev))
    end

    def changeset2(rev) # for UI history
        return self.extract2(self.revision2(rev))
    end
                            # node, new, "merge", co, cn
                            # node, new, "commit"
    def addchangeset(manifest, list, desc, p1=nil, p2=nil)
        time1 = Time.new
        # p time1.inspect
        # try: user = os.environ["HGUSER"]
        # except: user = os.environ["LOGNAME"] + '@' + socket.getfqdn()
        user = "User_name"
        date = time1.inspect
        # p "datedate",date
        date = date[0...-6]
        # p "datedate",date
        date.sub!(" ", ";")
        # p "datedate",date
        list = list.sort
        # p "manifest!!!!!!!3333",manifest
        manifest.sub!("\n","")
        # p "manifest!!!!!!!3333",manifest
        l = [manifest, user, date] + list + ["", desc]
        text = ""
        # p "lll",l
        for e in l
            # text += (e.to_s + "\n")
            text += (e.to_s + " ")  
        end
        # p "changeset:after:texxt",text 
        # p "manifest,list,desc",manifest,list,desc
        # p "changelog problem", text
        # text = "".join([e + "\n" for e in l])
        # p "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        return self.addrevision(text, p1, p2)
    end

end
#########################################################


# class Repository
#     def initialize(path=None, create=0)
#         @path = path
#         # p "repo path: " + @path
#     end

      
#     def open(path, mode="r")
#         print "filelog.open is calling repository.open!"
#         return true
#     end

# end

    # def merge(self, other):
    #     changed = {}
    #     new = {}
    #     def accumulate(text):
    #         files = self.changelog.extract(text)[3]
    #         for f in files:
    #             print " ",f,"changed"
    #             changed[f] = 1

    #     # begin the import/merge of changesets
    #     print "beginning changeset merge"
    #     (co, cn) = self.changelog.mergedag(other.changelog, accumulate)

    #     if co == cn: return

    #     # merge all files changed by the changesets,
    #     # keeping track of the new tips
    #     changed = changed.keys()
    #     changed.sort()
    #     for f in changed:
    #         print "merging", f
    #         f1 = filelog(self, f)
    #         f2 = filelog(other, f)
    #         rev = f1.merge(f2)
    #         if rev:
    #             new[f] = f1.node(rev)

    #     # begin the merge of the manifest
    #     print "merging manifests"
    #     (mm, mo) = self.manifest.mergedag(other.manifest)
    #     ma = self.manifest.ancestor(mm, mo)

    #     # resolve the manifest to point to all the merged files
    #     print "resolving manifests"
    #     mmap = self.manifest.manifest(mm) # mine
    #     omap = self.manifest.manifest(mo) # other
    #     amap = self.manifest.manifest(ma) # ancestor
    #     nmap = {}

    #     for f, mid in mmap.items():
    #         if f in omap:
    #             if mid != omap[f]: 
    #                 nmap[f] = new.get(f, mid) # use merged version
    #             else:
    #                 nmap[f] = new.get(f, mid) # they're the same
    #             del omap[f]
    #         elif f in amap:
    #             if mid != amap[f]: 
    #                 pass # we should prompt here
    #             else:
    #                 pass # other deleted it
    #         else:
    #             nmap[f] = new.get(f, mid) # we created it

    #     del mmap

    #     for f, oid in omap.items():
    #         if f in amap:
    #             if oid != amap[f]:
    #                 pass # this is the nasty case, we should prompt here too
    #             else:
    #                 pass # probably safe
    #         else:
    #             nmap[f] = new.get(f, mid) # remote created it

    #     del omap
    #     del amap

    #     nm = self.manifest.addmanifest(nmap, mm, mo)
    #     node = self.manifest.node(nm)

    #     # Now all files and manifests are merged, we add the changed files
    #     # and manifest id to the changelog
    #     print "committing merge changeset"
    #     new = new.keys()
    #     new.sort()
    #     if co == cn: cn = -1
    #     # we should give the user an opportunity to edit the changelog desc
    #     self.changelog.addchangeset(node, new, "merge", co, cn)


# begin
#     # f = File.open("C:/Users/nevgivin/Desktop/test/index" , "r")
#     # p f
#     rev = 3
#     path = "nevgivin"
#     p path
#     repo = Repository.new(path)
#     # p repo
#     of = Filelog.new(repo, path)
#     p "!!!!!!!!!!!! manifest !!!!!!!!!!"
#     manObj = Manifest.new(repo)
#     map = manObj.manifest(3)
#     # manObj.addmanifest(map)
#     # p "!!!!!!!!!!!! Changelog !!!!!!!!!"
#     # chanObj = Changelog.new(repo)
#     # reObj = Revlog.new("index 123","data 123")
#     # text = reObj.revision(rev)
#     # res = chanObj.extract(text)
#     # p "the res of extract: ",res
#     # res2 = chanObj.changeset(rev)
#     # manifest = "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
#     # desc = "descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc"
#     # list = [1,2,3]
#     # resaddc = chanObj.addchangeset(manifest, list, desc)
   



# end