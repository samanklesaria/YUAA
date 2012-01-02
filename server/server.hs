{-# LANGUAGE ForeignFunctionInterface #-}
module Main where
import Network.Fancy
import Foreign
import Foreign.C.Types
import Foreign.C.String
import qualified Data.ByteString as BS
import System.IO
import Control.Monad

main = do
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        s <- mainString
        l <- liftM fromIntegral getStrSize
        bs <- BS.packCStringLen (s,l)
        BS.hPut h bs
        hFlush h
        sleepForever)
    sleepForever
    

foreign import ccall "stringmaker.h mainString" 
     mainString :: IO CString

foreign import ccall "stringmaker.h getStrSize" 
     getStrSize :: IO CInt
