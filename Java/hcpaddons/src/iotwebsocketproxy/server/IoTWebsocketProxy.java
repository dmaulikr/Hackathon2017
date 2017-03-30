package iotwebsocketproxy.server;

import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import java.util.*;
import java.util.concurrent.*;

@ServerEndpoint(value = "/iotwebsocketproxy/{scope}/{deviceid}/{type}")
public class IoTWebsocketProxy {
	private static Queue<Session> sessionQueue = new ConcurrentLinkedQueue<Session>();
	
	@OnOpen
	public void onOpen(Session session, @PathParam("scope") String scope, @PathParam("deviceid") String deviceid, @PathParam("type") String type, EndpointConfig config) {
		sessionQueue.add(session);
	}

	@OnError
	public void error(Session session, Throwable t) {
		sessionQueue.remove(session);
		System.err.println("Error on session " + session.getId());
	}

	@OnClose
	public void closedConnection(Session session) {
		sessionQueue.remove(session);
		System.out.println("session closed: " + session.getId());
	}

	@OnMessage
	public void onMessage(Session session, String msg, @PathParam("scope") String scope, @PathParam("deviceid") String deviceid, @PathParam("type") String type) {	
		sendAll(msg, deviceid, type, session.getId());
	}

	private static void sendAll(String msg, String deviceid, String type, String sessionId) {
		String msgExtended = msg; 
		try {
			ArrayList<Session> closedSessions = new ArrayList<>();
			Session callingSession = null;
			for (Session session : sessionQueue) {
				if (!session.isOpen()) {
					System.err.println("Closed session: " + session.getId());
					closedSessions.add(session);
				} else {
					if(session.getId().equals(sessionId)){
						callingSession = session;
					}else{
						session.getBasicRemote().sendText(msgExtended);
					}
				}
			}
			sessionQueue.removeAll(closedSessions);
			System.out.println("Sending " + msg + " to " + sessionQueue.size() + " clients");
			if(callingSession != null){
				callingSession.getBasicRemote().sendText("Data has been processed");
			}
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}

}
