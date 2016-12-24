load "Revlog.rb"
require 'Pathname'

class Repository
  include Mdiff

  attr_accessor :changelog , :manifest


  def initialize(path = nil , create = 0)
    # p "repo path",path
    if not path
      cur_path = Dir.getwd()
      # p cur_path
      while not Dir.exists?(File.join(cur_path,".hg"))
        tmp_path = File.dirname(cur_path)
        # p cur_path
        raise "No Repo found" if cur_path == tmp_path
        cur_path = tmp_path
      end
      path = cur_path
    end
   
    @root = path
    @path = File.join(path ,".hg")
    
    # p @path   
    if create != 0
      Dir.mkdir(@path)
      Dir.mkdir(File.join(@path , "data"))
      Dir.mkdir(File.join(@path , "index"))
    end

    @manifest = Manifest.new(self)
    # p 'mmmmmmmmmmmmmmmmm',@manifest.tip()
    @changelog = Changelog.new(self)

    begin
      @current = open("current").read()
    rescue
      @current = nil
    end
  end


  def join(f)
    # p '????????????>>>>>>>>>>>>>>>>>'
    s = File.join(@path,f)
    # p s
    return s
  end

  def open(path, mode = "r")
    f = join(path)
    # p f
    if mode == "a" and File.file?(f)
      if File.stat(f).nlink > 1
        File.new(f + ".tmp" , "w").write(File.open(f).read())
        File.rename(f + ".tmp",f)
      end
    end
    # p f
    # p mode
    return File.open(f,mode)
  end

  def file(f)
    return Filelog.new(self,f)
  end

  def checkdir(path)
    d = File.dirname(path)
    if not d
      return
    end
    if not Dir.exist?(d)
      checkdir(d)
      Dir.mkdir(d)
    end
  end


  def add(list)
    al = open("to-add","a")
    st = open("dircache", "w")

    list.each do |e|
      al.puts(e)
      s = File.stat(e)
      st.write(String(s.mode) +"," + String(s.size) +","+ String(s.mtime) +","+ String(e.length) +","+ String(e))
    end
  end


  def delete(list)
    dl = open("to-delete" , "a")
    list.each do |e|
      dl.puts(e)
    end
  end

  def commit
      begin
          update = []
          # print '!!!'
          self.open("to-add").each_line do |f|
            # p f
            update << f
          end
      rescue 
        # print '???'
      end

      begin
          delete = []
          self.open("to-delete").each_line do |f|
            delete << f
          end
      rescue 
      end
      
      # p delete
      # p update
      #check in files
      news = {}
      
      update.each{|f|
          # p "!"
          f = f.delete("\n")
          # p "fffff!!!!!ffffffffff"
          r = Filelog.new(self,f)
          t = File.new(f).read()
          # p t
          r.addrevision(t)
          # p "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
          news[f] = r.node(r.tip())
      }
      # p "news!!!!!", news
      # p "mantip: ",@manifest.tip()
      old = @manifest.manifest(@manifest.tip())
      # p " before !!!!!!!!!!!!!!!!!! old!!:  ",old

      old.update(news)
      delete.each{|f|
          # p '1111111111111111',f
          old.delete(f)
      }
      
      # p "!!!!!!!!!!!!!!!!!! old!!:  ",old
      rev = @manifest.addmanifest(old)
      # p "manmanmanmanmanmanmanmanmanman"
      # p @manifest.tip()
      #add changeset
      news = news.keys
      news.sort
      

      n = @changelog.addchangeset(@manifest.node(rev), news, "commit\n")
      @current = n
      # p @current
      self.open("current", "w").write(String(@current))

      
      # p update
      #Special method for Ruby on Windows
      
    if update != []
      _delete = false;
      while _delete == false
        begin
            File.unlink(self.join("to-add"))
            _delete = true    
        rescue 
          
        end
      end
    end
      if delete != []
          _delete = false
          while _delete == false
              begin
                # print _delete
                File.unlink(self.join("to-delete")) 
                _delete = true    
              rescue 
          
              end
          end
      end
      

      # self.join("to-delete").unlink if delete
end

def diffdir()
  st = self.open("dircache").read()
  tmp = st.split(',')
  dc = Hash.new
  dc[tmp[4]] = tmp[0...3]
  # p dc
  

  change = Array.new
  added = Array.new

  # Dir[@root].each do |e|
  #   p e
  # end
  self.bottomup_path_walk(@root) do |e|
    state = File.stat(e)
    fname = File.basename(e)
    if dc.has_key?(fname)
      c = dc[fname]
      dc.delete(fname)
      if c[1] != String(state.size)
        p 'C ' + fname
      elsif c[0] != state.mode or c[2] != state.mtime
        t1 = File.open(fname, "r").read()
         # p Integer(@current)
        t2 = self.file(fname)
        # p t2.index
        # p t2.start(0)       
        if t1 != t2
          p 'C ' + fname
        end
      end
    else
      p 'A ' + fname
    end
    
  end
  deleted = dc.keys
  deleted.sort
  deleted.each do |e|
    p 'D ' + e
  end
  # p 'over'
end

def bottomup_path_walk(dir, &block)
  files = []
  subdirs = []
  Dir.glob(File.join(dir, "*")).each do |path_str|
    path = Pathname.new(path_str)
    if path.directory?
      bottomup_path_walk(path, &block)
      subdirs << path
    elsif path.file?
      files << path
    end
  end

  files.each   { |f| yield f }
  subdirs.each { |d| yield d }
end

def checkout(rev)
  change = @changelog.changeset(rev)
  mnode = change[0]
  # p "mnode",mnode
  marr = Array.new
  marr = mnode.split(" ")
  # p marr
  mmap = @manifest.manifest(@manifest.rev(marr[0]))
  # p "mmap mmap haha", mmap

  st = self.open("dircache", "w")
  
  l = mmap.keys# old: keys
  vv = mmap.values
  l.sort
  vv.sort
  # p "lll shi lllll", l,vv
  l.each do |f|           
    r = Filelog.new(self,f)
    # p "hh rrrrrrrrrrrrrrrr", f,r
    # p "mmap f ", mmap[f], f
    # p r.rev(mmap[f])
    # t = r.revision(r.rev(mmap[f])) 
    nodeidid = vv[0]
    # p "vvvvvvvv",nodeidid
    # nodeidid.slice! "d41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427e"
    # nodeidid += "d41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427e"
    # p "revision::::", f, r.rev(nodeidid)
    t = r.revision(r.rev(nodeidid))
    begin
      File.open(f, "w").write(t)
    rescue
      self.checkdir(f)
      File.open(f, "w").write(t)
    end
    s = File.stat(f)
    st.write(String(s.mode) + "," + String(s.size) +"," + String(s.mtime) + "," + String(f.length) + "," + String(f))
  end
  @current = change
  self.open("current", "w").write(String(@current))
end


def merge(other)
    changed = {}
    news = {}

    # http://stackoverflow.com/questions/522720/passing-a-method-as-a-parameter-in-ruby
    accumulate = Proc.new do |text|
      # p "text",text
      files = @changelog.extract(text)[3]
      # p "files",files
      files.each do |e|
        p " ",e,"changed"
        changed[e] = 1
      end
    end

    p "beginning changeset merge"


    # revlog1!!!!!!!!!!!!!!!
    # p "parm 1",other.changelog
    # p "accumulate",accumulate
    tmp = @changelog.mergedag(other.changelog , accumulate)
    # p "tmp::",tmp
    co = tmp[0]
    cn = tmp[1]

    if co == cn
        p "no need for merge"
        return
    end
    # p "changed!!!!!!!!!!hash ",changed
    changed = changed.keys
    # p "changed!!!!!!!!!!!!",changed
    changed.sort

    changed.each do |e|
      p "merging",e
      f1 = Filelog.new(self,e)
      f2 = Filelog.new(other,e)
      rev = f1.merge(f2)
      if rev
        news[e] = f1.node(rev)
      end
    end

    p "merging manifests"

    # revlog1!!!!!!!!!!!!!!!
    temp = @manifest.mergedag(other.manifest)
    mm = temp[0]
    mo = temp[1]
    # p "old tip",mm
    # p "new tip",mo
    ma = @manifest.ancestor(mm,mo)

    p "resolving manifests"

    mmap = @manifest.manifest(mm)
    omap = @manifest.manifest(mo)
    amap = @manifest.manifest(ma)

    # p "mmap",mmap
    # p "omap",omap
    # p "amap",amap

    namp = {}

    mmap.each do |key,value|
      if omap.has_key?(key)
        if news.has_key?(key)
          namp[key] = news[key]
        else
          namp[key] = value
        end
        omap.delete(key)
      elsif amap.has_key?(key)
      else
        if news.has_key?(key)
          namp[key] = news[key]
        else
          namp[key] = value
        end
      end
    end

    omap.each do |key,value|
      if amap.has_key?(key)
      else
        if news.has_key?(key)
          namp[key] = news[key]
        else
          namp[key] = value
        end
      end
    end

    # if nmap != {}
    nm = @manifest.addmanifest(namp,mm,mo)
    node = @manifest.node(nm)
    # p "nm",nm
    # end

    p "committing merge changeset"

    news = news.keys
    news.sort

    if co == cn
      cn = -1
    end
    # p "node::",node
    # p "news::",news
    @changelog.addchangeset(node , news , "MERGE\n" , co , cn) 
    p "merge succeed!!"
end

end
