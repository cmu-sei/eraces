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

package edu.cmu.sei.eraces.aadl.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.emf.common.util.URI;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.osate.aadl2.SystemImplementation;
import org.osate.aadl2.instance.SystemInstance;
import org.osate.aadl2.instantiation.InstantiateModel;

import edu.cmu.sei.eraces.aadl.Activator;
import edu.cmu.sei.eraces.aadl.logic.OptimizationLogic;
import edu.cmu.sei.eraces.aadl.util.SelectionHelper;

public class OptimizationHandler extends AbstractHandler {
	private SystemImplementation systemImplementation;

	public OptimizationHandler() {
		System.out.println("[OptimizationHandler] constructor");

	}

	protected final SystemImplementation systemImplementation() {
		return this.systemImplementation;
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		System.out.println("[OptimizationHandler] started");
		final IWorkbench wb = PlatformUI.getWorkbench();
		final IWorkbenchWindow window = wb.getActiveWorkbenchWindow();

		this.systemImplementation = SelectionHelper.getSelectedSystemImplementation();
		if (this.systemImplementation != null) {
			// Get the project that contains the system implementation
			final URI uri = systemImplementation.eResource().getURI();
			final IPath projectPath = new Path(uri.toPlatformString(true)).uptoSegment(1);
			final IResource projectResource = ResourcesPlugin.getWorkspace().getRoot().findMember(projectPath);

			Job job = new Job("ERACES") {
				@Override
				protected IStatus run(IProgressMonitor monitor) {
					System.out.println("[OptimizationHandler] here");
					SystemInstance instance;
					try {
						instance = InstantiateModel.buildInstanceModelFile(systemImplementation);
						OptimizationLogic logic = new OptimizationLogic(instance);
						logic.process();
						logic.getReport().export();
						projectResource.refreshLocal(IResource.DEPTH_INFINITE, null);
						// Refresh the project
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

					return Status.OK_STATUS;
				}
			};

			job.setPriority(Job.LONG);
			job.schedule();
		} else {
			MessageDialog.openError(window.getShell(), Activator.PLUGIN_ID, "Please select a System Implementation");
		}

		return null;
	}
}
