package net.tw.webapis.fotolia.util {
	import net.tw.webapis.fotolia.*;
	//import mx.utils.ObjectUtil;
	/**
	 * Utility class to convert Objects to Fotolia specific types.
	 */
	public class DataParser {
		public static function objectToArray(o:Object):Array {
			var a:Array=[];
			for each(var item:* in o) a.push(item);
			return a;
		}
		public static function firstObjectItemToArray(o:Object):Array {
			for each(var item:* in o) return objectToArray(item);
			return [];
		}
		public static function firstObjectItemToBoolean(o:Object):Boolean {
			for each(var item:* in o) return item;
			return false;
		}
		public static function firstObjectItemToObject(o:Object):* {
			for each(var item:* in o) return item;
			return null;
		}
		public static function objectArrayToFirstObjectItemArray(a:Array):Array {
			var ar:Array=[];
			for each (var item:Object in a) ar.push(firstObjectItemToObject(item));
			return ar;
		}
		/*
		public static function traceObject(o:Object):Object {
			trace('traceObject--');
			trace(ObjectUtil.toString(o));
			return o;
		}
		*/
		public static function getDataParser(o:Object):Object {
			o.languages=objectToArray(o.languages);
			return o;
		}
		public static function parseUser(o:Object, params:Array):FotoliaUser {
			return new FotoliaUser(params[0], o.session_id, params[1], params[2]);
		}
		public static function arrayToGalleries(a:Array, params:Array):Array {
			var gs:Array=[];
			for each (var item:Object in a) {
				gs.push(new FotoliaGallery(params[0], item));
			}
			return gs;
		}
		public static function arrayToUserGalleries(a:Array, params:Array):Array {
			var gs:Array=[];
			for each (var item:Object in a) {
				gs.push(new FotoliaUserGallery(params[0], item, params[1]));
			}
			return gs;
		}
		public static function createdGalleryToUserGallery(o:Object, params:Array):FotoliaUserGallery {
			o.name=params[2];
			return new FotoliaUserGallery(params[0], o, params[1]);
		}
		public static function successStringObjectToBoolean(o:Object):Boolean {
			for each(var item:* in o) return item=='SUCCESS';
			return false;
		}
		public static function objectToCategories(o:Object, params:Array):Array {
			var cs:Array=[];
			for each(var item:Object in o) {
				cs.push(new FotoliaCategory(params[0], item, params[1], params[2], params[3]));
			}
			return cs;
		}
		public static function objectToSearchResults(o:Object, params:Object):FotoliaSearchResults {
			var medias:Array=[];
			for (var p:String in o) {
				if (!/^[0-9]*$/.test(p)) continue;
				medias.push(new FotoliaMedia(params[0], o[p]));
			}
			return new FotoliaSearchResults(o.nb_results, medias);
		}
	}
}