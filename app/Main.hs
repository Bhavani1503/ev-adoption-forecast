-- Main.hs

import System.IO
import System.Process (callCommand)
import Data.List
import Data.List.Split (splitOn)

type Row = (Int, Double)

-- Parse CSV
parseCSV :: String -> [Row]
parseCSV content =
    let ls = tail (lines content)
    in map (\l -> let [y,v] = splitOn "," l
                  in (read y, read v)) ls

-- Lazy fold to compute cumulative growth
lazyFoldGrowth :: [Row] -> [(Int, Double)]
lazyFoldGrowth = scanl1 (\(_,prev) (y,v) -> (y, prev + v*0.05))

-- Convert to JSON
toJSON :: [(Int, Double)] -> String
toJSON xs =
    "[\n" ++ intercalate ",\n"
        [ "{ \"year\": " ++ show y ++ ", \"value\": " ++ show v ++ " }"
        | (y,v) <- xs ] ++ "\n]"

main :: IO ()
main = do
    putStrLn "Reading CSV..."

    content <- readFile "data/ev_sales.csv"
    let rows = parseCSV content

    -- Lazy fold computation
    let result = lazyFoldGrowth rows

    putStrLn "Writing JSON..."
    writeFile "output.json" (toJSON result)

    putStrLn "Opening Dashboard..."

    callCommand "python3 -m http.server 8000 --directory web"

    putStrLn "Done!"
