{-# LANGUAGE ForeignFunctionInterface #-}
module Main where
import Network.Fancy
import Foreign
import Foreign.C.Types
import Foreign.C.String
import System.IO

main = do
    streamServer serverSpec{address = (IP "localhost" 9000)} (\h a-> do
        tag1 <- newCString "AL"
        value1 <- newCString "102"
        str1 <- peekCString (createProtocolMessage tag1 value1)
        hPutStrLn h str1
        hFlush h
        tag2 <- newCString "AL"
        value2 <- newCString "200"
        str2 <- peekCString (createProtocolMessage tag2 value2)
        hPutStrLn h str2
        hFlush h)
    sleepForever
    

foreign import ccall "Parser.h createProtocolMessage"
     createProtocolMessage :: CString -> CString -> CString
