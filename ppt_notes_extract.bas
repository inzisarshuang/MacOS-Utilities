Attribute VB_Name = "模块1"
Sub SaveNotesUniversal()
    Dim sld As Slide
    Dim notesText As String
    Dim allNotes As String
    Dim i As Integer
    Dim fileNum As Integer
    Dim filePath As String
    
    ' 初始化
    allNotes = ""
    i = 1
    
    ' 收集所有备注
    For Each sld In ActivePresentation.Slides
        If sld.NotesPage.Shapes.Count > 1 Then
            On Error Resume Next
            notesText = sld.NotesPage.Shapes(2).TextFrame.TextRange.Text
            If Err.Number = 0 And notesText <> "" Then
                allNotes = allNotes & "幻灯片" & i & ":" & vbCrLf
                allNotes = allNotes & notesText & vbCrLf & vbCrLf
            End If
            On Error GoTo 0
        End If
        i = i + 1
    Next sld
    
    ' 自动检测系统并设置路径
    #If Mac Then
        ' filePath = MacScript("return (path to desktop as string)") & "PPT_Notes.txt"
        filePath = Environ$("HOME") & "/Desktop/PPT_Notes.txt"
    #Else
        filePath = Environ("USERPROFILE") & "\Desktop\PPT_Notes.txt"
    #End If
    
    fileNum = FreeFile()
    
    ' 写入文件
    Open filePath For Output As fileNum
    Print #fileNum, allNotes
    Close fileNum
    
    MsgBox "备注已保存到桌面：PPT_Notes.txt"
End Sub
