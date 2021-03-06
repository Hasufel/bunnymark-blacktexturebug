package tests;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.display.StageQuality;
import openfl.display.Tilesheet;
import flash.display.BlendMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

/**
 * @author Joshua Granick
 * @author Philippe Elsass
 */
class NoBatchTilesheetTest extends Sprite 
{
	var tf:TextField;	
	var numBunnies:Int;
	var incBunnies:Int;
	var smooth:Bool;
	var gravity:Float;
	var bunnies:Array <Bunny>;
	var bunnyDrawArrays: Array<Array<Float>>;
	var maxX:Int;
	var minX:Int;
	var maxY:Int;
	var minY:Int;
	var bunnyAsset:BitmapData;
	var drawList:Array<Float>;
	
	var pirates:Array<Bitmap>;
	var rf:flash.text.TextField;
	
	public function new() 
	{
		super ();
		
		minX = 0;
		maxX = Env.width;
		minY = 0;
		maxY = Env.height;
		
		gravity = 0.5;
		incBunnies = 100;
		#if flash
		smooth = false;
		numBunnies = 100;
		Lib.current.stage.quality = StageQuality.LOW;
		#else
		smooth = true;
		numBunnies = 500;
		#end

		pirates = [];
		for (i in 0...100) {
			addPirate();
		}
		
		bunnies = new Array<Bunny>();
		bunnyDrawArrays = new Array<Array<Float>>();
		drawList = new Array<Float>();
		
		var bunny; 
		for (i in 0...numBunnies) 
		{
			bunny = new Bunny();
			bunny.position = new Point();
			bunny.speedX = Math.random() * 5;
			bunny.speedY = (Math.random() * 5) - 2.5;
			bunny.scale = 0.3 + Math.random();
			bunny.rotation = 15 - Math.random() * 30;
			bunny.tilesheet = getTilesheet();
			bunnies.push(bunny);
			bunnyDrawArrays.push ([ 0.0, 0, 0, 0, 0, 0 ]);
		}
		
		createCounter();
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
		Lib.current.stage.addEventListener(Event.RESIZE, stage_resize);
		stage_resize(null);
	}
	
	function getTilesheet():Tilesheet {
		var bd = Assets.getBitmapData("assets/wabbit_alpha.png", false);
		var t:Tilesheet = new Tilesheet(bd);
		t.addTileRect(new Rectangle(0, 0, bd.width, bd.height));
		return t;
	}
	
	function addPirate():Void {
		var pirate = new Bitmap(Assets.getBitmapData("assets/pirate.png", false), PixelSnapping.AUTO, true);
		pirate.scaleX = pirate.scaleY = Env.height / 768;
		addChild(pirate);
		pirates.push(pirate);
	}

	function createCounter()
	{
		var format = new TextFormat("_sans", 20, 0, true);
		format.align = TextFormatAlign.RIGHT;

		tf = new TextField();
		tf.selectable = false;
		tf.defaultTextFormat = format;
		tf.width = 200;
		tf.height = 60;
		tf.x = maxX - tf.width - 10;
		tf.y = 10;
		addChild(tf);

		tf.addEventListener(MouseEvent.CLICK, counter_click);
		
		var format2 = new TextFormat("_sans", 20, 0, true);
		format2.align = TextFormatAlign.RIGHT;
		
		rf = new TextField();
		rf.text = "REMOVE";
		rf.selectable = false;
		rf.defaultTextFormat = format2;
		rf.width = 200;
		rf.height = 60;
		rf.x = maxX - rf.width -10;
		rf.y = tf.y + tf.height + 10;
		addChild(rf);
		
		rf.addEventListener(MouseEvent.CLICK, remove_click);
	}

	function counter_click(e)
	{
		if (numBunnies >= 1500) incBunnies = 250;
		var more = numBunnies + incBunnies;

		var bunny; 
		for (i in numBunnies...more)
		{
			bunny = new Bunny();
			bunny.position = new Point();
			bunny.speedX = Math.random() * 5;
			bunny.speedY = (Math.random() * 5) - 2.5;
			bunny.scale = 0.3 + Math.random();
			bunny.rotation = 15 - Math.random() * 30;
			bunny.tilesheet = getTilesheet();
			bunnies.push (bunny);
			bunnyDrawArrays.push ([ 0.0, 0, 0, 0, 0, 0 ]);
		}
		numBunnies = more;

		stage_resize(null);
	}
	
	function remove_click(_) {
		var less = numBunnies - incBunnies;
		var bunny;
		for (i in less...numBunnies) {
			bunnyDrawArrays.shift();
			bunny = bunnies.shift();
			if (bunny != null) {
				//bunny.tilesheet = null;
				//bunny = null;
				
			}
		}
		numBunnies = less;
		
		stage_resize(null);
	}
	
	function stage_resize(e) 
	{
		maxX = Env.width;
		maxY = Env.height;
		tf.text = "Bunnies:\n" + numBunnies;
		tf.x = maxX - tf.width - 10;
		rf.x = maxX - rf.width - 10;
	}
	
	function enterFrame(e) 
	{	
		graphics.clear ();

		var TILE_FIELDS = 6; // x+y+index+scale+rotation+alpha
		var bunny;
		var drawArray;
	 	for (i in 0...numBunnies)
		{
			bunny = bunnies[i];
			bunny.position.x += bunny.speedX;
			bunny.position.y += bunny.speedY;
			bunny.speedY += gravity;
			bunny.alpha = 0.3 + 0.7 * bunny.position.y / maxY;
			
			if (bunny.position.x > maxX)
			{
				bunny.speedX *= -1;
				bunny.position.x = maxX;
			}
			else if (bunny.position.x < minX)
			{
				bunny.speedX *= -1;
				bunny.position.x = minX;
			}
			if (bunny.position.y > maxY)
			{
				bunny.speedY *= -0.8;
				bunny.position.y = maxY;
				if (Math.random() > 0.5) bunny.speedY -= 3 + Math.random() * 4;
			} 
			else if (bunny.position.y < minY)
			{
				bunny.speedY = 0;
				bunny.position.y = minY;
			}
			
			drawArray = bunnyDrawArrays[i];
			
			drawArray[0] = bunny.position.x;
			drawArray[1] = bunny.position.y;
			//drawArray[2] = 0; // sprite index
			drawArray[3] = bunny.scale;
			drawArray[4] = bunny.rotation;
			drawArray[5] = bunny.alpha;
			
			bunny.tilesheet.drawTiles (graphics, [ bunny.position.x, bunny.position.y, 0, bunny.scale, bunny.rotation, bunny.alpha ], smooth, Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA);
		}

		var t = Lib.getTimer();
		var px = 0;
		for(pirate in pirates) {
			pirate.x = Std.int((Env.width - pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)) + px) ;
			pirate.y = Std.int(Env.height - pirate.height + 70 - 30 * Math.sin(t / 100));
			px += Std.int(Math.random() * 100);
		}
	}
	
	
}