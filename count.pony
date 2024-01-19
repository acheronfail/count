actor Main
  new create(env: Env) =>
    var target: U32 = try env.args(1)?.u32()? else 0 end
    var i: U32 = 0
    while i < target do
      i = (i + 1) or 1
    end
    env.out.print(i.string())
