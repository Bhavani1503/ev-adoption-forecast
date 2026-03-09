module Main where

import System.IO
import Text.Printf

-- Split CSV line by comma
splitComma :: String -> [String]
splitComma [] = []
splitComma s =
  let (w, s') = break (== ',') s
  in w : case s' of
       [] -> []
       (_:rest) -> splitComma rest

-- Convert CSV row to (Year, Sales)
parseRow :: String -> (Int, Double)
parseRow row =
  let parts = splitComma row
  in (read (parts !! 0), read (parts !! 1))

-- Read CSV dataset
readCSV :: String -> [(Int, Double)]
readCSV content =
  let rows = tail (lines content)
  in map parseRow rows

-- Calculate average growth using fold
avgGrowth :: [(Int, Double)] -> Double
avgGrowth xs =
  let sales = map snd xs
      diffs = zipWith (-) (tail sales) sales
  in foldl (+) 0 diffs / fromIntegral (length diffs)

-- Logistic prediction model
predictEV :: Double -> Double -> Double -> Int -> Double
predictEV k r t year =
  k / (1 + exp (-r * (fromIntegral year - t)))

main :: IO ()
main = do

  putStrLn "Reading EV dataset..."

  content <- readFile "data/ev_sales.csv"

  let dataset = readCSV content
  let growth = avgGrowth dataset

  putStrLn ("Average Growth Rate: " ++ show growth)

  -- Carrying capacity (max EV market size estimate)
  let k = 100000000

  -- Midpoint year
  let t = 2025

  -- Predict EV adoption
  let predictions =
        [ (year, predictEV k growth t year)
        | year <- [2024..2030]
        ]

  putStrLn "\nPredicted EV Adoption:"
  mapM_ print predictions

  -- Convert predictions to CSV
  let csvHeader = "Year,Prediction\n"
  let csvRows = concatMap (\(y,v) -> show y ++ "," ++ show v ++ "\n") predictions
  let output = csvHeader ++ csvRows

  writeFile "results/predictions.csv" output

  putStrLn "\nPredictions saved to results/predictions.csv"
