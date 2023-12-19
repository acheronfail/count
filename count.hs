import System.Environment

count :: Int -> Int -> IO ()
count target n
    | n == target = print n
    | otherwise   = count target (n + 1)

main :: IO ()
main = do
    [arg] <- getArgs
    let target = read arg
    count target 0
