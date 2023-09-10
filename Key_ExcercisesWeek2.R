###Key exercises wk 2
library(tidyverse)
# 1.    Make two vectors, object `a` containing the values 2, 3, 4, and 5 and object `b`containing the values 50, 100, 38, and 42.

a = c(2:5)
a

b = c(50, 100, 38, 42)
b

# 2.    Multiply object `a` by 3 and assign it to a new object, divide object `b` by 5 and assign it to a new object, then add the new two objects together. 
c = a*3
c

d = b/5
d

# 3.    Create a new `data.frame`/`tibble` with the four objects created above
df_ex1 = data.frame(a = a, b = b, c = c, d = d)
df_ex1

# 4.    Save the `data.frame`/`tibble` created in exercise 3 as a .csv
write.csv(df_ex1, "./data/df_ex1.csv") #path name will be case specifice - i.e., depending on the coder's working directory

# 5.    Load in files a.csv and b.csv (found on [github](https://github.com/BSC6926-B52-Fall2023/workshopScripts/tree/main/data) and canvas) and assign each as an object.
a_new = read.csv("./data/a.csv")
b_new = read.csv("./data/a.csv")
