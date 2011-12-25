{-# LANGUAGE ForeignFunctionInterface #-}
module Main where
import Network.Fancy
import Foreign
import Foreign.C.Types
import Foreign.C.String
import qualified Data.ByteString as BS
import System.IO

main = do
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        s <- mainString
        let len = (160*120*3)
        bs <- BS.packCStringLen (s,2*(len + 5))
        BS.hPut h bs
        BS.writeFile "/Users/sam/Desktop/bsfile" bs
        hFlush h
        sleepForever)
    sleepForever
    

foreign import ccall "stringmaker.h mainString" 
     mainString :: IO CString
