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

import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.views.contentoutline.ContentOutline;
import org.eclipse.xtext.resource.EObjectAtOffsetHelper;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;
import org.osate.aadl2.Classifier;
import org.osate.aadl2.Element;
import org.osate.aadl2.SystemImplementation;

public class SelectionHelper {
	private static EObjectAtOffsetHelper eObjectAtOffsetHelper = new EObjectAtOffsetHelper();

	public static ISelection getSelection() {
		IWorkbench wb = PlatformUI.getWorkbench();
		IWorkbenchWindow win = wb.getActiveWorkbenchWindow();
		IWorkbenchPage page = win.getActivePage();
		IWorkbenchPart part = page.getActivePart();
		IEditorPart activeEditor = page.getActiveEditor();
		if (activeEditor == null) {
			throw new RuntimeException("Unexpected case. Unable to get active editor");
		}

		final ISelection selection;
		if (part instanceof ContentOutline) {
			selection = ((ContentOutline) part).getSelection();
		} else {
			selection = getXtextEditor().getSelectionProvider().getSelection();
		}

		return selection;
	}

	// Based on code in: org.osate.xtext.aadl2.ui.handlers.InstantiateHandler
	// Gets the selected model object
	public static EObject getSelectedObject() {
		return getEObjectFromSelection(getSelection());
	}

	public static EObject getEObjectFromSelection(final ISelection selection) {
		return getXtextEditor().getDocument().readOnly(new IUnitOfWork<EObject, XtextResource>() {
			public EObject exec(XtextResource resource) throws Exception {
				EObject targetElement = null;
				if (selection instanceof IStructuredSelection) {
					IStructuredSelection ss = (IStructuredSelection) selection;
					Object eon = ss.getFirstElement();
					if (eon instanceof EObjectNode) {
						targetElement = ((EObjectNode) eon).getEObject(resource);
					}
				} else {
					targetElement = eObjectAtOffsetHelper.resolveElementAt(resource,
							((ITextSelection) selection).getOffset());
				}

				return targetElement;
			}
		});
	}

	public static SystemImplementation getSelectedSystemImplementation() {
		return getSelectedSystemImplementation(getSelection());
	}

	// Returns the SystemImplementation that is currently selected. If the
	// current selection is an object inside a SystemImplementation, such as a
	// PropertyAssociation, the SystemImplementaiton
	// is returned. If the selection is not inside a SystemImplementation, then
	// null is returned
	public static SystemImplementation getSelectedSystemImplementation(ISelection selection) {
		EObject selectedObject = getEObjectFromSelection(selection);

		// Return the object if it is a system implementation
		if (selectedObject instanceof SystemImplementation) {
			return (SystemImplementation) selectedObject;
		}

		// Otherwise, check if it is contained in a system implementation. This
		// should work in cases where the selection is a property association,
		// etc
		if (selectedObject instanceof Element) {
			Element aadlObject = (Element) selectedObject;
			Classifier containingClassifier = aadlObject.getContainingClassifier();
			if (containingClassifier instanceof SystemImplementation) {
				return (SystemImplementation) containingClassifier;
			}
		}

		return null;
	}

	public static XtextEditor getXtextEditor() {
		IWorkbench wb = PlatformUI.getWorkbench();
		IWorkbenchWindow win = wb.getActiveWorkbenchWindow();
		IWorkbenchPage page = win.getActivePage();
		IEditorPart activeEditor = page.getActiveEditor();
		if (activeEditor == null) {
			throw new RuntimeException("Unexpected case. Unable to get active editor");
		}

		XtextEditor xtextEditor = (XtextEditor) activeEditor.getAdapter(XtextEditor.class);
		if (xtextEditor == null) {
			throw new RuntimeException("Unexpected case. Unable to get Xtext editor");
		}

		return xtextEditor;
	}
}
