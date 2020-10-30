module Program

[<RequireQualifiedAccess>]
type Stack<'T> =
    | Empty
    | Stack of 'T * Stack<'T>

    member inline s.Push x = Stack(x, s)
    
    member inline s.Pop () =
        match s with
        | Stack(t, _) -> t
        | Empty -> failwith "Stack underflow"

[<EntryPoint>]
let main argv =
    printfn "Arturo on .NET Core"
    let stack = (Stack.Empty).Push 2
    stack.Pop () |> ignore
    let stack = stack.Push 3
    printfn "%d" (stack.Pop ())
    0
