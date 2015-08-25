/*
 * Copyright (c) 2015 Carnegie Mellon University.
 * All Rights Reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS," WITH NO WARRANTIES WHATSOEVER. CARNEGIE 
 * MELLON UNIVERSITY EXPRESSLY DISCLAIMS TO THE FULLEST EXTENT PERMITTEDBY 
 * LAW ALL EXPRESS, IMPLIED, AND STATUTORY WARRANTIES, INCLUDING, WITHOUT 
 * LIMITATION, THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
 * AND NON-INFRINGEMENT OF PROPRIETARY RIGHTS.
 *
 * This Program is distributed under a BSD license.  Please see LICENSE.TXT file
 * or permission@sei.cmu.edu for more information.  
 * DM-0002674
 */

package edu.cmu.sei.eraces.aadl.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.osate.aadl2.EnumerationLiteral;
import org.osate.aadl2.instance.ComponentInstance;
import org.osate.aadl2.instance.ConnectionInstance;
import org.osate.aadl2.instance.ConnectionInstanceEnd;
import org.osate.aadl2.instance.FeatureInstance;
import org.osate.xtext.aadl2.properties.util.GetProperties;

public class Utils {

	public static ComponentInstance getComponent(ConnectionInstanceEnd end) {
		ComponentInstance result;
		result = null;

		if (end instanceof ComponentInstance) {
			result = (ComponentInstance) end;
		}

		if (end instanceof FeatureInstance) {
			result = ((FeatureInstance) end).getContainingComponentInstance();
		}

		return result;
	}

	private static List<ComponentInstance> inspected = null;

	public static List<ComponentInstance> getDestinationsRec(FeatureInstance destination) {
		List<ComponentInstance> result;
		ComponentInstance destinationComponent;
		EnumerationLiteral destinationDispatch;
		double destinationPeriod;

		result = new ArrayList<ComponentInstance>();
		destinationComponent = Utils.getComponent(destination);
		destinationDispatch = GetProperties.getDispatchProtocol(destinationComponent);
		destinationPeriod = GetProperties.getPeriodinMS(destinationComponent);

		/**
		 * The component has already been visited.
		 */
		if (inspected.contains(destinationComponent)) {
			return result;
		}

		/**
		 * The component has a period, considering taking the period.
		 */
		if (destinationPeriod > 0) {
			result.add(destinationComponent);
			return result;
		}

		if (GetProperties.getMaximumComputeExecutionTimeinMs(destinationComponent) > 0) {
			result.add(destinationComponent);
			return result;
		}

		/**
		 * The component is aperiodic, trying to 
		 */
		if (destinationDispatch.getName().equalsIgnoreCase("aperiodic")) {
			ComponentInstance topComponent = destinationComponent.getContainingComponentInstance();
			for (ConnectionInstance connection : topComponent.getConnectionInstances()) {
				if (Utils.getComponent(connection.getSource()) == destinationComponent) {
					result.addAll(getDestinationsRec((FeatureInstance) connection.getDestination()));
				}
			}
		}

		return result;
	}

	public static List<ComponentInstance> getDestinations(FeatureInstance destination) {
		inspected = new ArrayList<ComponentInstance>();
		List<ComponentInstance> res = getDestinationsRec(destination);
		inspected = null;
		return res;
	}

//	public static void addMarker(NamedElement ne, String message) {
//		IResource res = getResourceFromEObject(ne);
//		try {
//			IMarker marker = res.createMarker(IMarker.PROBLEM);
//			marker.setAttribute(IMarker.MESSAGE, message);
//			marker.setAttribute(IMarker.SEVERITY, new Integer(IMarker.SEVERITY_ERROR));
//			marker.setAttribute(Activator.ERACES_MARKER, "true");
//		} catch (CoreException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//			System.out.println("[Utils] addMarker exception");
//		}
//	}

	public static IResource getResourceFromEObject(EObject obj) {
		URI uri = obj.eResource().getURI();
		// assuming platform://resource/project/path/to/file
		String project = uri.segment(1);
		IPath path = new Path(uri.path()).removeFirstSegments(2);
		return ResourcesPlugin.getWorkspace().getRoot().getProject(project).findMember(path);
	}

}
