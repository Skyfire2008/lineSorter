package ;

import sys.io.File;

import haxe.ds.Vector;

import haxe.io.Output;
import haxe.io.Input;
import haxe.io.Bytes;

import format.png.Reader;
import format.png.Tools;
import format.png.Data;

class Main{

	private static var stderr: Output=Sys.stderr();
	private static var stdout: Output=Sys.stdout();

	private static var stdin: Input=Sys.stdin();

	private static var bytesIn: Bytes;
	private static var width: Int;
	private static var height: Int;

	static function main(){

		//var handler: ArgumentHandler=new ArgumentHandler();

		//read the image
		var reader=new Reader(File.read(Sys.args()[0]));
		var data=reader.read();
		var header=Tools.getHeader(data);
		width=header.width;
		height=header.height;
		bytesIn=Tools.extract32(data);

		//calculate the brightness of every line
		var colorAccum: Vector<Color>=new Vector<Color>(width);
		var brightnesses: Vector<Float>=new Vector<Float>(width);
		for(i in 0...width){
			var currentColor={r:0, g:0, b:0};

			for(j in 0...height){
				var pos=i*j>>2;
				currentColor.r+=bytesIn.get(pos);
				currentColor.g+=bytesIn.get(pos+1);
				currentColor.b+=bytesIn.get(pos+2);
			}

			colorAccum[i]=currentColor;
			brightnesses[i]=0.2126*currentColor.r + 0.7152*currentColor.g + 0.0722*currentColor.b;
		}

		trace(brightnesses);
	}
}

typedef Color={
	var r: Int;
	var g: Int;
	var b: Int;
}