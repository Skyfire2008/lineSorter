package ;

import haxe.ds.IntMap;
import haxe.ds.StringMap;

class ArgumentHandler{

	private var shortOptions: IntMap<CallbackHandler>;
	private var longOptions: StringMap<CallbackHandler>;

	public function new(){
		shortOptions=new IntMap<CallbackHandler>();
		longOptions=new StringMap<CallbackHandler>();
	}

	public function addArgOption(opt: Int, longOpt: String, callback: String -> Void){
		var option: CallbackHandler=new ArgCallbackHandler(callback);

		if(opt>=0){
			shortOptions.set(opt, option);
		}
		if(longOpt!=null){
			longOptions.set(longOpt, option);
		}
	}

	public function addNoArgOption(opt: Int, longOpt: String, callback: Void -> Void){
		var option: CallbackHandler=new NoArgCallbackHandler(callback);

		if(opt>=0){
			shortOptions.set(opt, option);
		}
		if(longOpt!=null){
			longOptions.set(longOpt, option);
		}
	}

	public function processArguments(args: Array<String>){
		var index: Int=0;

		while(index<args.length){
			var arg: String=args[index];
			var handler: CallbackHandler=null;

			if(arg.indexOf("--")==0){
				handler=longOptions.get(arg.substr(2));
			}else if(arg.indexOf("-")==0){
				handler=shortOptions.get(arg.charCodeAt(1));
			}

			if(handler==null){
				throw '$arg is not a valid option';
				break;
			}else{
				try{
					index=handler.apply(args, index);
				}catch(e: String){
					throw 'Option "$arg" was not used correctly:\n\t$e';
				}
			}
		}
	}

}

/**
 * @brief 						Contains callback function to be called when a specific option is encountered
 */
interface CallbackHandler{

	/**
	 * @brief 					Applies option callback function to argument array
	 * @param args				Argument array
	 * @param index				Index of option in the array
	 * 
	 * @return 					New index
	 */
	public function apply(args: Array<String>, index: Int): Int;

}

/**
 * @brief 						Contains callback for options, requiring an argument
 */
class ArgCallbackHandler implements CallbackHandler{

	private var callback: String -> Void;

	public function new(callback: String -> Void){
		this.callback=callback;
	}

	public function apply(args: Array<String>, index: Int){
		var argIndex=index+1;

		if(argIndex>=args.length){
			throw "No argument found";
		}else{
			callback(args[argIndex]);
		}

		return argIndex+1;
	}
}

/**
 * @brief 						Contains callback for options, requiring no arguments
 */
class NoArgCallbackHandler implements CallbackHandler{

	private var callback: Void -> Void;

	public function new(callback: Void -> Void){
		this.callback=callback;
	}

	public function apply(args: Array<String>, index: Int){
		callback();
		return index+1;
	}
}