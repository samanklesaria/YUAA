import System.IO
import Network.Fancy

main = withStream (IP "localhost" 9000) (\h-> hGetLine h >>= putStrLn)