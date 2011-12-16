{-# LANGUAGE ForeignFunctionInterface #-}
module Main where
import Network.Fancy
import Foreign
import Foreign.C.Types
import Foreign.C.String
import System.IO

main = do
    -- initCrc8
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        initCrc8
        tag1 <- newCString "LA"
        value1 <- newCString "41.5"
        str1 <- peekCString (createProtocolMessage tag1 value1)
        hPutStr h str1
        tag2 <- newCString "LN"
        value2 <- newCString "-73.0"
        str2 <- peekCString (createProtocolMessage tag2 value2)
        hPutStr h str2
        tag3 <- newCString "AL"
        value3 <- newCString "200"
        str3 <- peekCString (createProtocolMessage tag3 value3)
        hPutStr h str3
        tag4 <- newCString "AL"
        value4 <- newCString "300"
        str4 <- peekCString (createProtocolMessage tag4 value4)
        hPutStr h str4
        hFlush h
        sleepForever)
    sleepForever
    

foreign import ccall "Parser.h createProtocolMessage"
     createProtocolMessage :: CString -> CString -> CString


foreign import ccall "Parser.h initCrc8"
     initCrc8 :: IO ()