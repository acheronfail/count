program count
  integer :: i, target
  character(len=10) :: arg

  call getarg(1, arg)
  read(arg,*) target

  i = 0
  do while (i < target)
    i = mod(i + 1, 2000000000);
  end do

  print *, i
end program count
