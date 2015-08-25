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

package edu.cmu.sei.eraces.aadl;

import java.io.File;
import java.net.URISyntaxException;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.URIUtil;
import org.eclipse.osgi.service.datalocation.Location;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleConstants;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IConsoleView;
import org.eclipse.ui.console.MessageConsole;
import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;

public class Utils {

	public static boolean isPathValid(final String path) {
		// Try to evaluate a path as being relative to the eclipse installation directory
		File eclipseDirectory = getEclipseHome();
		if (eclipseDirectory != null) {
			File file = new File(eclipseDirectory, path);
			if (file.exists()) {
				return true;
			}
		}

		return new File(path).exists();
	}

	private static File getEclipseHome() {
		BundleContext context = Activator.getDefault().getBundle().getBundleContext();
		try {
			for (ServiceReference<Location> ref : context.getServiceReferences(Location.class,
					Location.ECLIPSE_HOME_FILTER)) {
				Location location = context.getService(ref);
				if (location != null && location.isSet()) {
					return URIUtil.toFile(URIUtil.toURI(location.getURL())).getAbsoluteFile();
				}
			}
		} catch (InvalidSyntaxException e) {
		} catch (URISyntaxException e) {
		}

		return null;
	}

	public static int returnValue() {
		if (!isWindows())
			return 0;
		else
			return 2; // TODO
	}

	public static boolean isWindows() {
		String os = System.getProperty("os.name").toLowerCase();
		return (os.indexOf("win") >= 0);
	}

	public static MessageConsole findConsole(String name) {
		ConsolePlugin plugin = ConsolePlugin.getDefault();
		IConsoleManager conMan = plugin.getConsoleManager();
		IConsole[] existing = conMan.getConsoles();
		for (int i = 0; i < existing.length; i++)
			if (name.equals(existing[i].getName()))
				return (MessageConsole) existing[i];
		// No console found, so create a new one
		MessageConsole myConsole = new MessageConsole(name, null);
		conMan.addConsoles(new IConsole[] { myConsole });
		return myConsole;
	}

	public static void showConsole(final IConsole console) {
		Display.getDefault().asyncExec(new Runnable() {
			@Override
			public void run() {
				IWorkbench workbench = PlatformUI.getWorkbench();
				IWorkbenchWindow window = workbench.getActiveWorkbenchWindow();
				if (window != null) {
					IWorkbenchPage page = window.getActivePage();
					if (page != null) {
						try {
							IConsoleView view = (IConsoleView) page.showView(IConsoleConstants.ID_CONSOLE_VIEW);
							view.display(console);
						} catch (PartInitException e) {
							throw new RuntimeException(e);
						}
					}
				}
			}
		});

	}

	/**
	 * Find all files in the current workspace whose name matches a specified pattern
	 * @param namePattern is the pattern the name must match
	 * @return the list of files
	 */
	public static java.util.List<IFile> findFilesInWorkspaceByName(final java.util.regex.Pattern namePattern) {
		return findFilesByName(ResourcesPlugin.getWorkspace().getRoot(), namePattern, null);
	}

	/**
	 * Find all files in the current workspace whose name matches a specified pattern
	 * @param namePattern is the pattern the name must match
	 * @param files the list that matching files are added to. A list is created if null.
	 * @return the list of files
	 */
	public static java.util.List<IFile> findFilesInWorkspaceByName(final java.util.regex.Pattern namePattern,
			java.util.List<IFile> files) {
		return findFilesByName(ResourcesPlugin.getWorkspace().getRoot(), namePattern, files);
	}

	/**
	 * Find all children files of a specified container whose name matches a specified pattern
	 * @param parent
	 * @param namePattern is the pattern the name must match
	 * @param files the list that matching files are added to. A list is created if null.
	 * @return the list of files
	 */
	public static java.util.List<IFile> findFilesByName(final IContainer parent,
			final java.util.regex.Pattern namePattern, java.util.List<IFile> files) {
		// Create the list if it doesn't exist
		if (files == null) {
			files = new java.util.ArrayList<IFile>();
		}

		try {
			// Find files with names that match the specified pattern
			for (IResource member : parent.members()) {
				if (member instanceof IContainer) {
					findFilesByName((IContainer) member, namePattern, files);
				} else if (member instanceof IFile) {
					String name = member.getName();
					if (namePattern.matcher(name).matches()) {
						files.add((IFile) member);
					}
				}
			}
		} catch (CoreException ex) {
			throw new RuntimeException(ex);
		}

		return files;
	}

	public static String getAbsoluteFilepath(IResource resource) {
		File file = resource.getLocation().toFile();

		return file.getAbsolutePath();
	}
}
