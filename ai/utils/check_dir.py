import os
from glob import glob


def check_dir(save_directory, reverse_check_num=10):
    if not os.path.isdir(f"save/{save_directory}"):
        """처음 초기화하는 경우"""
        print("모델을 저장할 디렉토리를 생성합니다.")
        os.makedirs(f"save/{save_directory}")
        if os.path.isdir(f"save/{save_directory}"):
            print("생성완료")

        return save_directory

    elif os.path.isdir(f"save/{save_directory}") and not bool(
        glob(f"save/{save_directory}/*.pt")
    ):  # 디렉토리는 생성했지만 저장한 모델이 없는 경우
        return save_directory

    elif (
        os.path.isdir(f"save/{save_directory}")
        and bool(glob(f"save/{save_directory}/*.pt"))
        and not bool(glob(f"save/{save_directory}/*.csv"))
    ):  # 훈련이 끝나고 inference만 하고 싶은 경우 마지막 디렉토리를 탐색
        last_directory = f"{save_directory}_{reverse_check_num}"
        number = reverse_check_num
        while last_directory not in os.listdir("save"):
            number -= 1
            if number < 10:
                str_num = "0" + str(number)
            else:
                str_num = str(number)

            if number > 0:
                last_directory = f"{save_directory}_{str_num}"
            else:
                last_directory = f"{save_directory}"
        print(f"inference 결과가 담길 디렉토리는 {last_directory}입니다.")

        return last_directory

    else:
        print(
            "파일이 덮여씌여지는 것을 방지하기 위해 새로운 디렉토리를 생성합니다. 필요없는 모델은 확인 후 삭제해주세요."
        )
        number = 1
        # next_directory가 없을때까지 다음 번호를 부여하면서 체크
        str_num = "0" + str(number)
        next_directory = f"{save_directory}_{str_num}"
        while next_directory in os.listdir("save"):
            number += 1
            if number < 10:
                str_num = "0" + str(number)
            else:
                str_num = str(number)
            next_directory = f"{save_directory}_{str_num}"

        os.makedirs(f"save/{next_directory}")
        if os.path.isdir(f"save/{next_directory}"):
            print("생성완료")

        return next_directory
