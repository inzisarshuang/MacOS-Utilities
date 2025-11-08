Attribute VB_Name = "ExportPPTNotes"
' ============================================================
' 函数1：导出备注为TXT格式
' ============================================================
Sub ExportNotesToTXT()
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
        notesText = "(No Notes)"
        
        ' 检查是否有备注内容
        If sld.NotesPage.Shapes.Count > 1 Then
            On Error Resume Next
            notesText = sld.NotesPage.Shapes(2).TextFrame.TextRange.text
            If Err.Number <> 0 Or Trim(notesText) = "" Then
                notesText = "(No Notes)"
            End If
            On Error GoTo 0
        End If
        
        ' 添加到总文本
        allNotes = allNotes & "Slide " & i & ":" & vbCrLf
        allNotes = allNotes & CleanText(notesText, "TXT") & vbCrLf & vbCrLf
        
        i = i + 1
    Next sld
    
    ' 设置文件路径并写入
    filePath = GetDesktopPath() & "PPT_Notes.txt"
    fileNum = FreeFile()
    
    Open filePath For Output As fileNum
    Print #fileNum, allNotes
    Close fileNum
    
    MsgBox "Notes exported to: PPT_Notes.txt" & vbCrLf & "Total slides processed: " & i - 1
End Sub

' ============================================================
' 函数2：导出备注为CSV格式
' ============================================================
Sub ExportNotesToCSV()
    Dim sld As Slide
    Dim notesText As String
    Dim i As Integer
    Dim fileNum As Integer
    Dim filePath As String
    Dim csvLine As String
    
    ' 初始化
    i = 1
    
    ' 设置文件路径
    filePath = GetDesktopPath() & "PPT_Notes.csv"
    fileNum = FreeFile()
    
    ' 打开文件并写入CSV表头
    Open filePath For Output As fileNum
    Print #fileNum, "SlideID,NotesContent"  ' CSV header
    
    ' 为每一张幻灯片创建条目
    For Each sld In ActivePresentation.Slides
        notesText = "(No Notes)"
        
        ' 检查是否有备注内容
        If sld.NotesPage.Shapes.Count > 1 Then
            On Error Resume Next
            notesText = sld.NotesPage.Shapes(2).TextFrame.TextRange.text
            If Err.Number <> 0 Or Trim(notesText) = "" Then
                notesText = "(No Notes)"
            End If
            On Error GoTo 0
        End If
        
        ' 处理备注内容中的特殊字符
        notesText = CleanText(notesText, "CSV")
        
        ' 构建CSV行
        csvLine = "Slide" & i & "," & Chr(34) & notesText & Chr(34)
        
        ' 写入文件
        Print #fileNum, csvLine
        
        i = i + 1
    Next sld
    
    Close fileNum
    MsgBox "Notes exported to: PPT_Notes.csv" & vbCrLf & "Total slides processed: " & i - 1
End Sub

' ============================================================
' 调试函数：测试路径获取
' ============================================================
Sub TestPath()
    ' 这个函数可以帮助您测试哪种路径获取方法有效
    Dim TestPath As String
    
    TestPath = GetDesktopPath()
    
    MsgBox "当前桌面路径为：" & vbCrLf & TestPath & _
           vbCrLf & vbCrLf & "如果这个路径不正确，请修改 GetDesktopPath 函数中的路径选项。"
End Sub

' ============================================================
' 通用函数：获取桌面路径（多种选项）
' ============================================================
Function GetDesktopPath() As String
    #If Mac Then
        ' ===== Mac 系统 =====
        
        ' 优先尝试使用环境变量获取路径
        On Error Resume Next
        GetDesktopPath = Environ("HOME") & "/Desktop/"
        If Err.Number = 0 And GetDesktopPath <> "" Then
            On Error GoTo 0
            Exit Function
        End If
        On Error GoTo 0
        
        ' 如果环境变量方法失败，使用 AppleScript 获取路径
        On Error Resume Next
        GetDesktopPath = MacScript("return (path to desktop as string)")
        If Err.Number = 0 Then
            On Error GoTo 0
            Exit Function
        End If
        On Error GoTo 0
        
        ' 如果自动方法都失败，使用硬编码路径
        GetDesktopPath = "/Users/inzisarshuang/Desktop/"
        
    #Else
        ' ===== Windows 系统 =====
        
        ' 优先尝试使用环境变量获取路径
        On Error Resume Next
        GetDesktopPath = Environ("USERPROFILE") & "\Desktop\"
        If Err.Number = 0 And GetDesktopPath <> "" Then
            On Error GoTo 0
            Exit Function
        End If
        On Error GoTo 0
        
        ' 如果环境变量方法失败，使用硬编码路径
        GetDesktopPath = "C:\Users\YourUsername\Desktop\"
        
    #End If
End Function

' ============================================================
' 通用函数：清理文本内容
' ============================================================
Function CleanText(text As String, Optional formatType As String = "TXT") As String
    If Trim(text) = "" Then
        CleanText = "(No Notes)"
        Exit Function
    End If
    
    Select Case formatType
        Case "CSV"
            ' CSV格式需要特殊处理
            CleanText = Replace(text, Chr(34), "'")  ' 替换双引号
            CleanText = Replace(CleanText, ",", "，")   ' 替换英文逗号
            CleanText = Replace(CleanText, vbCrLf, " | ")  ' 替换换行符
            CleanText = Replace(CleanText, vbCr, " | ")
            CleanText = Replace(CleanText, vbLf, " | ")
        Case Else
            ' TXT格式保持原样
            CleanText = text
    End Select
End Function

