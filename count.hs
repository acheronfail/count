count :: Int -> IO ()
count 1000000000 = print 1000000000
count n = do
  count (n + 1)

main :: IO ()
main = count 0
