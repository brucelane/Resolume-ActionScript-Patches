package resolume.core {
	
	public interface IFileReference {
		
		function get name():String;
		function get path():String;
		function get extension():String;
		function get isDirectory():Boolean;
		
		function getParent():IFileReference;
		function resolve(path:String):IFileReference;
		
	}
}