require "zlib"
require "base64"

def compress_encode(str)
    # p "original string = ", str
    compress_str = Zlib::Deflate.deflate(str)
    # p "compressed string = ", compress_str
    encoded_str = Base64.encode64 compress_str
    # p "encoded_str = ", encoded_str
    encoded_str.tr!("\n", "*")
    # p "compress: after replace", encoded_str
    encoded_str = encoded_str.chomp("*")
    # p "encoded_str 2",encoded_str
    encoded_str = encoded_str + "\n"
    # p "encoded_str 3",encoded_str
    return encoded_str
    # return str
end

def decompress_decode(encoded_data)
    # p "origin Decompress & decode: encoded_str = ", encoded_data
    encoded_data.tr!("*", "\n")
    # p "Decompress & decode: encoded_str = ", encoded_data
    base = Base64.decode64(encoded_data)
    # p "decompress base", base
    str2 = Zlib::Inflate.inflate(base)
    # p "Back to original data = ", str2
    return str2
    # return encoded_data
end

# str = "0 194 0 -1 -1 d41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427ed41d8cd98f00b204e9800998ecf8427e987654321asda@t1.txt User_name 2016-11-14;19:01:05 t1.txt  commit  "
# c = compress_encode(str)
# # p "compress str = ", c


# s = "eJzNjjEOwjAUQ3dO4Quk+v6N4KcsvQQzKsmvxBCQIEOPTyuugETt0U+2aT1U*DbI6ECWyWC7JZpGbSvRkIimZ59minnzvOcfGri3t3z/28vNXO7ppbLp1HXB5*++v6mKpDhcdABpUzOTAO2uNLAflZ632l8QHp1KUz\n"
# ss = decompress_decode(s)
# p ss


# p "after replace: ", c



# str2 = decompress_decode(c)
# raise "err" if str != str2