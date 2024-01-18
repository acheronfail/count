let () =
  let target = int_of_string Sys.argv.(1) in
  let rec loop i =
    if i < target
    then loop ((i + 1) lor 1)
    else Printf.printf "%d\n" i
  in loop 0
