import os
import shutil
import webbrowser
import platform
import subprocess
from urllib.parse import unquote
from tkinter import Tk, Label, Frame, Button, Entry, StringVar, filedialog, messagebox, Checkbutton, IntVar
from tkinterdnd2 import TkinterDnD, DND_FILES

previous_output_dir = None  # 이전 경로 저장

def is_file_downloaded(file_path):
    if not os.path.isfile(file_path):
        return False
    if file_path.endswith(".icloud"):
        return False
    try:
        os.stat(file_path)
        return True
    except OSError:
        return False

def is_path_accessible(file_path):
    try:
        os.stat(file_path)  # 파일 상태 확인
        return True
    except PermissionError:
        print(f"권한이 없습니다: {file_path}")
        return False
    except FileNotFoundError:
        print(f"파일을 찾을 수 없습니다: {file_path}")
        return False
    except OSError as e:
        print(f"경로 접근 오류: {file_path}, {e}")
        return False


def get_unique_filename(directory, filename):
    """
    중복 파일명을 처리하기 위해 '(1)', '(2)' 형식으로 번호를 추가
    """
    base, ext = os.path.splitext(filename)
    counter = 1
    unique_filename = filename
    while os.path.exists(os.path.join(directory, unique_filename)):
        unique_filename = f"{base}({counter}){ext}"
        counter += 1
    return unique_filename


def decode_filenames(file_paths, output_dir=None, preserve_original=True):
    """
    파일 이름 디코딩 및 중복 파일 처리
    """
    processed_files = set()
    skipped_files = []

    for file_path in file_paths:
        try:
            file_path = clean_path(file_path)
            if file_path in processed_files:
                continue
            processed_files.add(file_path)

            if not os.path.exists(file_path):
                print(f"파일 경로가 존재하지 않음: {file_path}")
                skipped_files.append(file_path)
                continue

            # 파일 이름 디코딩
            dir_name, file_name = os.path.split(file_path)
            decoded_name = unquote(file_name)

            # 출력 디렉토리 결정 (없으면 원본 파일 위치 사용)
            target_dir = output_dir if output_dir else dir_name

            # 저장 경로 및 중복 처리
            temp_copy_path = os.path.join(target_dir, decoded_name)
            if os.path.exists(temp_copy_path):
                temp_copy_path = os.path.join(target_dir, get_unique_filename(target_dir, decoded_name))

            if preserve_original:
                shutil.copy2(file_path, temp_copy_path)  # 파일 복사
                print(f"복사됨: {file_path} -> {temp_copy_path}")
            else:
                shutil.move(file_path, temp_copy_path)  # 파일 이동
                print(f"이동됨: {file_path} -> {temp_copy_path}")

        except Exception as e:
            print(f"진행 실패: {file_path}")
            print(f"오류: {e}")
            skipped_files.append(file_path)

    processed_count = len(processed_files) - len(skipped_files)

    # 스킵된 파일 목록 표시
    if skipped_files:
        skipped_list = "\n".join(skipped_files)
        messagebox.showinfo(
            "스킵된 파일",
            f"다음 파일들이 스킵되었습니다:\n{skipped_list}"
        )
    else:
        messagebox.showinfo("진행 완료", "모든 파일이 성공적으로 처리되었습니다.")


def clean_path(file_path):
    """
    경로 문자열을 클린업
    """
    file_path = file_path.strip("{}")
    file_path = file_path.replace("\xa0", " ")
    return file_path


def request_full_disk_access():
    if platform.system() == "Darwin":  # MacOS에서만 실행
        message = (
            "이 프로그램이 전체 디스크 접근 권한을 필요로 합니다.\n"
            "1. '시스템 설정'을 열고\n"
            "2. '개인정보 보호 및 보안 > 전체 디스크 접근'으로 이동한 후\n"
            "3. 터미널(Terminal) 또는 Python 인터프리터를 추가하세요.\n\n"
            "지금 '시스템 설정'을 열까요?"
        )
        response = messagebox.askyesno("전체 디스크 접근 권한 요청", message)
        if response:
            # 시스템 설정 열기
            subprocess.call(["open", "/System/Library/PreferencePanes/Security.prefPane"])

# GitHub 링크 열기 함수
def open_github():
    webbrowser.open("https://github.com/adgk2349/")

def create_gui():
    root = TkinterDnD.Tk()
    root.title("파일 이름 디코더 for MAC")
    root.geometry("600x400")
    root.minsize(600, 400)


    global output_dir_var, save_to_desktop_var, preserve_original_var, browse_button

    output_dir_var = StringVar(value=os.path.join(os.path.expanduser("~"), "Desktop"))
    save_to_desktop_var = IntVar(value=1)
    preserve_original_var = IntVar(value=1)

    # 상단 타이틀 프레임 (제목 + GitHub 링크)
    title_frame = Frame(root)
    title_frame.pack(fill="x", pady=5)

    # GitHub 링크
    github_label = Label(
        title_frame,
        text="@Made by 방구석_코드스미스",
        font=("Arial", 10),
        fg="grey",
        cursor="hand2"
    )
    github_label.pack(side="right", padx=10)

    # 마우스 이벤트로 색상 반전
    github_label.bind("<Enter>", lambda e: github_label.configure(fg="white"))  # 색상 반전
    github_label.bind("<Leave>", lambda e: github_label.configure(fg="grey"))  # 원래 상태로 복원

    # 클릭 이벤트로 GitHub 열기
    github_label.bind("<Button-1>", lambda e: open_github())

    # 출력 경로 선택 UI
    frame = Frame(root)
    frame.pack(pady=10, fill="x")

    Label(frame, text="저장 경로:").pack(side="left", padx=5)
    output_entry = Entry(frame, textvariable=output_dir_var, state="disabled")  # 비활성화
    output_entry.pack(side="left", fill="x", expand=True, padx=5)
    browse_button = Button(frame, text="찾기", state="disabled", command=lambda: open_output_dir_dialog(output_entry))  # 비활성화
    browse_button.pack(side="left", padx=5)

    # 옵션 설정
    options_frame = Frame(root)
    options_frame.pack(pady=10, fill="x")

    Checkbutton(
        options_frame,
        text="바탕화면에 저장",
        variable=save_to_desktop_var,
        command=lambda: toggle_save_to_desktop(output_entry, browse_button)
    ).pack(side="left", padx=5)

    Checkbutton(
        options_frame,
        text="기존 파일 유지",
        variable=preserve_original_var
    ).pack(side="left", padx=5)

    # 파일 선택 버튼 오른쪽 정렬
    file_button = Button(options_frame, text="파일 찾기", command=open_file_dialog)
    file_button.pack(side="right", padx=5)

    # 분리된 선 추가
    separator = Frame(root, height=2, bd=1, relief="sunken", bg="grey")
    separator.pack(fill="x", pady=10)

    # 드롭 영역
    drop_area = Label(root, text="파일 끌어다놓기", font=("Arial", 12))  # 배경색 제거
    drop_area.pack(fill="both", expand=True)
    drop_area.drop_target_register(DND_FILES)
    drop_area.dnd_bind("<<Drop>>", lambda event: on_drop(event, output_dir_var.get(), preserve_original_var.get()))

    root.mainloop()

def open_file_dialog():
    """파일 선택 대화 상자를 열어 여러 파일을 선택"""
    file_paths = filedialog.askopenfilenames(title="파일 선택")
    if file_paths:
        output_dir = output_dir_var.get()
        preserve_original = preserve_original_var.get()
        decode_filenames(file_paths, output_dir, preserve_original)

def open_output_dir_dialog(output_entry):
    global save_to_desktop_var, previous_output_dir, browse_button
    dir_path = filedialog.askdirectory(title="저장 경로 선택")
    if dir_path:
        output_entry.config(state="normal")
        output_entry.delete(0, "end")
        output_entry.insert(0, dir_path)
        output_dir_var.set(dir_path)
        desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
        if dir_path == desktop_path:
            save_to_desktop_var.set(1)
            output_entry.config(state="disabled")
            browse_button.config(state="disabled")
        else:
            save_to_desktop_var.set(0)
            output_entry.config(state="normal")
            browse_button.config(state="normal")
        previous_output_dir = dir_path

def toggle_save_to_desktop(output_entry, browse_button):
    global previous_output_dir
    if save_to_desktop_var.get() == 1:
        previous_output_dir = output_dir_var.get()
        desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
        output_dir_var.set(desktop_path)
        output_entry.config(state="disabled")
        browse_button.config(state="disabled")
    else:
        if previous_output_dir:
            output_dir_var.set(previous_output_dir)
        output_entry.config(state="normal")
        browse_button.config(state="normal")

def on_drop(event, output_dir, preserve_original):
    files = event.data.split()
    decode_filenames(files, output_dir, preserve_original)

if __name__ == "__main__":
    create_gui()