out = open("sssssssut.txt", "w")

lines = []
with open("ascii.txt", "r") as file:
    for l in file.readlines():
        lines.append('"' + l.replace("\n", "") + '",\n')


out.writelines(lines)
out.close()

print("hello")  

