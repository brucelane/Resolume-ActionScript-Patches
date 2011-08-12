package resolume.core {
	
	public interface ISerializable {
		
		function unserialize(object:Object):Boolean;
		function serialize():Object;
	}
}